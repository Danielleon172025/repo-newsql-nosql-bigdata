"""Recoleccion y limpieza del conjunto abierto 'Familias focalizadas - Familias en Accion
(Puerto Boyaca)' publicado en datos.gov.co.

Entrada : data/raw/familias_accion_puerto_boyaca.csv
Salidas : data/clean/beneficiarios_limpio.csv   (para mongoimport)
          scripts/newsql/02_carga_beneficiarios.sql (INSERT por lotes para CockroachDB)
          evidencias/00_perfilado_datos.txt     (perfil de calidad antes/despues)
Uso     : python 01_recoleccion_limpieza.py
"""
import csv
import collections
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
ENTRADA = RAIZ / "data" / "raw" / "familias_accion_puerto_boyaca.csv"
SALIDA_CSV = RAIZ / "data" / "clean" / "beneficiarios_limpio.csv"
SALIDA_SQL = RAIZ / "scripts" / "newsql" / "02_carga_beneficiarios.sql"
SALIDA_PERFIL = RAIZ / "evidencias" / "00_perfilado_datos.txt"

COLUMNAS = [
    "id", "bancarizado", "discapacidad", "estado", "etnia", "fecha_inscripcion",
    "genero", "nivel_escolaridad", "tipo_documento", "tipo_poblacion",
    "rango_beneficio_total", "rango_ultimo_beneficio", "fecha_ultimo_beneficio",
    "rango_edad", "titular", "cantidad_beneficiarios",
]


def normaliza_texto(valor):
    valor = (valor or "").strip().replace("\ufffd", "-")
    return valor.upper() if valor else "ND"


def normaliza_fecha(valor):
    """Las fechas '1900-01-01' son un centinela de 'sin dato' -> NULL."""
    valor = (valor or "").strip()
    return "" if valor in ("", "1900-01-01") else valor


def sql_literal(valor):
    return "NULL" if valor == "" else "'" + str(valor).replace("'", "''") + "'"


def main():
    with open(ENTRADA, encoding="utf-8-sig", newline="") as f:
        crudo = list(csv.DictReader(f))

    nulos_antes = sum(1 for r in crudo for v in r.values() if not (v or "").strip())
    limpio = []
    for i, r in enumerate(crudo, start=1):
        limpio.append({
            "id": i,
            "bancarizado": normaliza_texto(r["Bancarizado"]),
            "discapacidad": normaliza_texto(r["Discapacidad"]),
            "estado": normaliza_texto(r["EstadoBeneficiario"]),
            "etnia": normaliza_texto(r["Etnia"]),
            "fecha_inscripcion": normaliza_fecha(r["FechaInscripcionBeneficiario"]),
            "genero": normaliza_texto(r["Genero"]),
            "nivel_escolaridad": normaliza_texto(r["NivelEscolaridad"]),
            "tipo_documento": normaliza_texto(r["TipoDocumento"]),
            "tipo_poblacion": normaliza_texto(r["TipoPoblacion"]),
            "rango_beneficio_total": normaliza_texto(r["RangoBeneficioConsolidadoAsignado"]),
            "rango_ultimo_beneficio": normaliza_texto(r["RangoUltimoBeneficioAsignado"]),
            "fecha_ultimo_beneficio": normaliza_fecha(r["FechaUltimoBeneficioAsignado"]),
            "rango_edad": normaliza_texto(r["RangoEdad"]),
            "titular": normaliza_texto(r["Titular"]),
            "cantidad_beneficiarios": int(r["CantidadDeBeneficiarios"] or 1),
        })

    SALIDA_CSV.parent.mkdir(parents=True, exist_ok=True)
    with open(SALIDA_CSV, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNAS)
        w.writeheader()
        w.writerows(limpio)

    with open(SALIDA_SQL, "w", encoding="utf-8") as f:
        f.write("USE familias_accion_db;\n\n")
        lote = 500
        for ini in range(0, len(limpio), lote):
            f.write("INSERT INTO beneficiarios (" + ", ".join(COLUMNAS) + ") VALUES\n")
            filas = []
            for r in limpio[ini:ini + lote]:
                vals = [str(r["id"])] + [sql_literal(r[c]) for c in COLUMNAS[1:-1]] + [str(r["cantidad_beneficiarios"])]
                filas.append("  (" + ", ".join(vals) + ")")
            f.write(",\n".join(filas) + ";\n\n")

    with open(SALIDA_PERFIL, "w", encoding="utf-8") as f:
        f.write(f"Registros leidos      : {len(crudo)}\n")
        f.write(f"Registros limpios     : {len(limpio)}\n")
        f.write(f"Celdas vacias (antes) : {nulos_antes}\n")
        f.write(f"Fechas centinela 1900 : {sum(1 for r in crudo if r['FechaUltimoBeneficioAsignado'].strip() == '1900-01-01')}\n\n")
        for c in ["genero", "estado", "tipo_poblacion", "rango_edad", "bancarizado", "etnia"]:
            f.write(f"{c}: {dict(collections.Counter(r[c] for r in limpio).most_common())}\n")
    print(SALIDA_PERFIL.read_text(encoding="utf-8"))


if __name__ == "__main__":
    main()
