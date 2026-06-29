#!/usr/bin/env python3
import pdfplumber
import json
from collections import defaultdict

pdf_path = r"C:\Users\Notebook\Downloads\SquadLists-English.pdf"

squads = defaultdict(lambda: {"GK": [], "DEF": [], "MID": [], "FWD": []})

with pdfplumber.open(pdf_path) as pdf:
    for page_num, page in enumerate(pdf.pages[:10]):  # Primeiras 10 páginas
        tables = page.extract_tables()

        if not tables:
            continue

        for table in tables:
            if not table or len(table) < 2:
                continue

            # Encontra o país/seleção no topo da tabela
            country = None
            for row in table[:3]:
                if row and len(row) > 0:
                    cell_text = str(row[0]).upper() if row[0] else ""
                    # Procura por padrão "COUNTRY (CODE)"
                    if "(" in cell_text and ")" in cell_text:
                        country = cell_text.split("(")[0].strip()
                        break

            if not country:
                continue

            # Processa as linhas da tabela
            for row in table:
                if not row or len(row) < 5:
                    continue

                pos = str(row[0]).strip() if row[0] else ""
                player_name = str(row[1]).strip() if len(row) > 1 and row[1] else ""

                # Pula headers
                if pos.upper() in ["POS", "POSITION"] or player_name.upper() == "PLAYER NAME":
                    continue

                # Normaliza posição
                pos = pos.upper()
                if pos not in ["GK", "DF", "MF", "FW"]:
                    continue

                # Converte posição para categoria
                if pos == "GK":
                    pos_cat = "GK"
                elif pos == "DF":
                    pos_cat = "DEF"
                elif pos == "MF":
                    pos_cat = "MID"
                elif pos == "FW":
                    pos_cat = "FWD"
                else:
                    continue

                if player_name and len(player_name) > 1:
                    squads[country][pos_cat].append(player_name)

            print(f"Page {page_num + 1}: Extraído {country}")

# Imprime resultado
print("\n" + "="*80)
print("ELENCOS EXTRAÍDOS")
print("="*80 + "\n")

for country in sorted(squads.keys()):
    data = squads[country]
    print(f"\n'{country}': {{")
    print(f"    GK:  {json.dumps(data['GK'][:3], ensure_ascii=False)},")
    print(f"    DEF: {json.dumps(data['DEF'][:10], ensure_ascii=False)},")
    print(f"    MID: {json.dumps(data['MID'][:10], ensure_ascii=False)},")
    print(f"    FWD: {json.dumps(data['FWD'][:8], ensure_ascii=False)},")
    print("},")
