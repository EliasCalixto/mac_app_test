import Foundation

// MARK: - Régimen pensionario

/// Régimen de pensiones del trabajador. Las tasas de AFP (comisión sobre flujo
/// y prima de seguro) cambian periódicamente; estos valores son referenciales.
enum RegimenPension: String, CaseIterable, Identifiable, Codable {
    case onp = "ONP"
    case habitat = "AFP Habitat"
    case integra = "AFP Integra"
    case prima = "AFP Prima"
    case profuturo = "AFP Profuturo"

    var id: String { rawValue }

    /// Aporte obligatorio al fondo de pensiones.
    var aporte: Double {
        switch self {
        case .onp: return 0.13
        default: return 0.10
        }
    }

    /// Comisión sobre flujo (solo AFP).
    var comision: Double {
        switch self {
        case .onp: return 0
        case .habitat: return 0.0147
        case .integra: return 0.0155
        case .prima: return 0.0160
        case .profuturo: return 0.0169
        }
    }

    /// Prima de seguro de invalidez y sobrevivencia (solo AFP).
    var primaSeguro: Double {
        switch self {
        case .onp: return 0
        default: return 0.0137
        }
    }

    var tasaTotal: Double { aporte + comision + primaSeguro }
}

// MARK: - Régimen de salud

enum RegimenSalud: String, CaseIterable, Identifiable {
    case essalud = "EsSalud"
    case eps = "EPS"

    var id: String { rawValue }

    /// Bonificación extraordinaria de la gratificación (Ley 30334).
    var bonificacionExtraordinaria: Double {
        switch self {
        case .essalud: return 0.09
        case .eps: return 0.0675
        }
    }
}

// MARK: - Resultados

struct ResultadoSueldoNeto {
    let remuneracionBruta: Double
    let descuentoPension: Double
    let aportePension: Double
    let comisionPension: Double
    let primaSeguro: Double
    let rentaQuintaMensual: Double
    let rentaQuintaAnual: Double
    let sueldoNeto: Double
    /// 12 sueldos netos + 2 gratificaciones con bonificación (asumiendo EsSalud).
    let ingresoAnualNeto: Double
    /// CTS acumulada en un año (2 depósitos semestrales completos).
    let ctsAnual: Double
}

struct ResultadoCuartaCategoria {
    let retencion: Double
    let neto: Double
    let sujetoARetencion: Bool
}

struct ResultadoGratificacion {
    let gratificacion: Double
    let bonificacionExtraordinaria: Double
    let total: Double
}

struct ResultadoCTS {
    let remuneracionComputable: Double
    let porMeses: Double
    let porDias: Double
    let total: Double
}

// MARK: - Calculadora

enum CalculadoraPlanilla {

    /// Sueldo neto mensual: bruto − pensión (AFP/ONP) − retención de renta de
    /// quinta categoría (proyección anual simple dividida entre 12).
    static func sueldoNeto(
        sueldoMensual: Double,
        asignacionFamiliar: Double,
        regimen: RegimenPension,
        uit: Double
    ) -> ResultadoSueldoNeto {
        let bruta = sueldoMensual + asignacionFamiliar

        let aporte = bruta * regimen.aporte
        let comision = bruta * regimen.comision
        let prima = bruta * regimen.primaSeguro
        let pension = aporte + comision + prima

        // Proyección anual: 12 sueldos + 2 gratificaciones. La pensión no se
        // descuenta de las gratificaciones, pero la renta de 5ta sí las grava.
        let ingresoAnual = bruta * 14
        let baseImponible = max(0, ingresoAnual - 7 * uit)
        let rentaAnual = impuestoAnual(baseImponible: baseImponible, uit: uit)
        let rentaMensual = rentaAnual / 12
        let neto = bruta - pension - rentaMensual

        // 12 sueldos netos + 2 gratificaciones (sin descuento de pensión) con
        // bonificación extraordinaria del 9% (EsSalud). La renta anual ya está
        // repartida en los 12 sueldos.
        let gratisAnuales = bruta * 2 * (1 + RegimenSalud.essalud.bonificacionExtraordinaria)
        let anualNeto = neto * 12 + gratisAnuales
        // CTS de un año: 2 depósitos de medio sueldo computable (sueldo + 1/6 de grati).
        let ctsAnual = bruta * 7 / 6

        return ResultadoSueldoNeto(
            remuneracionBruta: bruta,
            descuentoPension: pension,
            aportePension: aporte,
            comisionPension: comision,
            primaSeguro: prima,
            rentaQuintaMensual: rentaMensual,
            rentaQuintaAnual: rentaAnual,
            sueldoNeto: neto,
            ingresoAnualNeto: anualNeto,
            ctsAnual: ctsAnual
        )
    }

    /// Retención de renta de 4ta categoría (recibos por honorarios): 8% sobre
    /// el monto del recibo cuando supera el límite y el pagador es agente de
    /// retención.
    static let limiteRetencionRecibo = 1500.0

    static func cuartaCategoria(montoRecibo: Double) -> ResultadoCuartaCategoria {
        let sujeto = montoRecibo > limiteRetencionRecibo
        let retencion = sujeto ? montoRecibo * 0.08 : 0
        return ResultadoCuartaCategoria(
            retencion: retencion,
            neto: montoRecibo - retencion,
            sujetoARetencion: sujeto
        )
    }

    /// Ingreso mensual promedio por debajo del cual se puede solicitar a SUNAT
    /// la suspensión de retenciones de 4ta categoría. Aproximación derivada de
    /// la deducción del 20% y las 7 UIT: (7 UIT ÷ 0.8) ÷ 12.
    static func limiteSuspensionMensual(uit: Double) -> Double {
        (7 * uit / 0.8) / 12
    }

    /// Impuesto a la renta de 5ta categoría por tramos progresivos
    /// (8%, 14%, 17%, 20%, 30%) sobre la base imponible (ingreso anual − 7 UIT).
    static func impuestoAnual(baseImponible: Double, uit: Double) -> Double {
        let tramos: [(limite: Double, tasa: Double)] = [
            (5 * uit, 0.08),
            (20 * uit, 0.14),
            (35 * uit, 0.17),
            (45 * uit, 0.20),
            (.infinity, 0.30),
        ]

        var impuesto = 0.0
        var inferior = 0.0
        for tramo in tramos {
            guard baseImponible > inferior else { break }
            let gravado = min(baseImponible, tramo.limite) - inferior
            impuesto += gravado * tramo.tasa
            inferior = tramo.limite
        }
        return impuesto
    }

    /// Gratificación de julio o diciembre: un sueldo proporcional a los meses
    /// completos trabajados en el semestre, más la bonificación extraordinaria
    /// (9% EsSalud, 6.75% EPS). No tiene descuento de AFP/ONP.
    static func gratificacion(
        sueldoMensual: Double,
        asignacionFamiliar: Double,
        mesesTrabajados: Int,
        salud: RegimenSalud
    ) -> ResultadoGratificacion {
        let computable = sueldoMensual + asignacionFamiliar
        let meses = Double(min(max(mesesTrabajados, 0), 6))
        let grati = computable * meses / 6
        let bono = grati * salud.bonificacionExtraordinaria
        return ResultadoGratificacion(
            gratificacion: grati,
            bonificacionExtraordinaria: bono,
            total: grati + bono
        )
    }

    /// CTS del semestre (depósitos de mayo y noviembre):
    /// remuneración computable = sueldo + asignación + 1/6 de la última
    /// gratificación; se deposita 1/12 por mes completo y 1/360 por día.
    static func cts(
        sueldoMensual: Double,
        asignacionFamiliar: Double,
        ultimaGratificacion: Double,
        mesesCompletos: Int,
        diasAdicionales: Int
    ) -> ResultadoCTS {
        let computable = sueldoMensual + asignacionFamiliar + ultimaGratificacion / 6
        let meses = Double(min(max(mesesCompletos, 0), 6))
        let dias = Double(min(max(diasAdicionales, 0), 29))
        let porMeses = computable * meses / 12
        let porDias = computable * dias / 360
        return ResultadoCTS(
            remuneracionComputable: computable,
            porMeses: porMeses,
            porDias: porDias,
            total: porMeses + porDias
        )
    }
}

// MARK: - Fechas de planilla

/// Fechas límite legales de pago: gratificaciones el 15 de julio y 15 de
/// diciembre; depósitos de CTS el 15 de mayo y 15 de noviembre.
enum FechasPlanilla {
    static func proximaGratificacion(desde: Date = .now) -> Date {
        proxima(dia: 15, meses: [7, 12], desde: desde)
    }

    static func proximaCTS(desde: Date = .now) -> Date {
        proxima(dia: 15, meses: [5, 11], desde: desde)
    }

    static func diasHasta(_ fecha: Date, desde: Date = .now) -> Int {
        let cal = Calendar.current
        return cal.dateComponents(
            [.day],
            from: cal.startOfDay(for: desde),
            to: cal.startOfDay(for: fecha)
        ).day ?? 0
    }

    private static func proxima(dia: Int, meses: [Int], desde: Date) -> Date {
        let cal = Calendar.current
        let año = cal.component(.year, from: desde)
        var candidatas: [Date] = []
        for y in [año, año + 1] {
            for m in meses {
                if let fecha = cal.date(from: DateComponents(year: y, month: m, day: dia)) {
                    candidatas.append(fecha)
                }
            }
        }
        return candidatas.filter { $0 > desde }.min() ?? desde
    }
}

// MARK: - Formato de moneda

extension Double {
    private static let formateadorSoles: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "es_PE")
        f.currencyCode = "PEN"
        f.currencySymbol = "S/ "
        return f
    }()

    var enSoles: String {
        Double.formateadorSoles.string(from: NSNumber(value: self)) ?? "S/ 0.00"
    }
}
