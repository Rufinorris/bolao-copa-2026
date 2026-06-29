#!/usr/bin/env python3
"""
Script para buscar fotos dos 416 jogadores da Copa 2026 via Wikipedia API.
Rate limit: máximo 10 requisições por 2 segundos
"""

import json
import requests
import time
from datetime import datetime
from collections import OrderedDict
import unicodedata
import concurrent.futures
from threading import Lock

# Elencos completos
ELENCOS = {
    'Brasil': {
        'GK': ['Alisson','Ederson','Weverton'],
        'DEF': ['Marquinhos','Gabriel','Bremer','Ibanez','Leo Pereira','Danilo','Alex Sandro','Douglas Santos'],
        'MID': ['Casemiro','Bruno Guimaraes','Fabinho','Lucas Paqueta','Ederson'],
        'FWD': ['Vinicius Junior','Raphinha','Matheus Cunha','Luiz Henrique','Igor Thiago','Endrick','Gabriel Martinelli','Rayan','Neymar'],
    },
    'Argentina': {
        'GK': ['Emiliano Martinez','Juan Musso','Geronimo Rulli'],
        'DEF': ['Leonardo Balerdi','Lisandro Martinez','Facundo Medina','Nahuel Molina','Gonzalo Montiel','Nicolas Otamendi','Cristian Romero','Nicolas Tagliafico'],
        'MID': ['Valentín Barco','Rodrigo De Paul','Enzo Fernandez','Giovani Lo Celso','Alexis Mac Allister','Exequiel Palacios','Leandro Paredes'],
        'FWD': ['Thiago Almada','Julian Alvarez','Nicolas Gonzalez','Jose Manuel Lopez','Lautaro Martinez','Lionel Messi','Nicolas Paz','Giuliano Simeone'],
    },
    'França': {
        'GK': ['Mike Maignan','Robin Risser','Brice Samba'],
        'DEF': ['Lucas Digne','Malo Gusto','Lucas Hernandez','Theo Hernandez','Ibrahima Konate','Jules Kounde','Maxence Lacroix','William Saliba','Dayot Upamecano'],
        'MID': ['NGolo Kante','Manu Kone','Adrien Rabiot','Aurelien Tchouameni','Warren Zaire-Emery'],
        'FWD': ['Maghnes Akliouche','Bradley Barcola','Rayan Cherki','Ousmane Dembele','Desire Doue','Jean-Philippe Mateta','Kylian Mbappe','Michael Olise','Marcus Thuram'],
    },
    'Espanha': {
        'GK': ['Unai Simon','David Raya','Joan Garcia'],
        'DEF': ['Aymeric Laporte','Marc Cucurella','Marcos Llorente','Eric Garcia','Pedro Porro','Alex Grimaldo','Pau Cubarsi','Marc Pubill'],
        'MID': ['Rodri','Fabian Ruiz','Mikel Merino','Pedri','Gavi','Martin Zubimendi','Alex Baena'],
        'FWD': ['Ferran Torres','Mikel Oyarzabal','Dani Olmo','Nico Williams','Lamine Yamal','Yeremy Pino','Borja Iglesias','Victor Munoz'],
    },
    'Portugal': {
        'GK': ['Diogo Costa','Jose Sa','Rui Silva','Ricardo Velho'],
        'DEF': ['Diogo Dalot','Matheus Nunes','Nelson Semedo','Joao Cancelo','Nuno Mendes','Goncalo Inacio','Renato Veiga','Ruben Dias','Tomas Araujo'],
        'MID': ['Ruben Neves','Samuel Costa','Joao Neves','Vitinha','Bruno Fernandes','Bernardo Silva'],
        'FWD': ['Joao Felix','Francisco Trincao','Francisco Conceicao','Pedro Neto','Rafael Leao','Goncalo Guedes','Goncalo Ramos','Cristiano Ronaldo'],
    },
    'Alemanha': {
        'GK': ['Oliver Baumann','Manuel Neuer','Alexander Nubel'],
        'DEF': ['Waldemar Anton','Nathaniel Brown','David Raum','Antonio Rudiger','Nico Schlotterbeck','Jonathan Tah','Malick Thiaw'],
        'MID': ['Pascal Gross','Joshua Kimmich','Felix Nmecha','Aleksandar Pavlovic','Angelo Stiller','Leon Goretzka','Florian Wirtz'],
        'FWD': ['Maximilian Beier','Kai Havertz','Assan Ouedraogo','Jamal Musiala','Leroy Sane','Deniz Undav','Nick Woltemade','Jamie Leweling'],
    },
    'Inglaterra': {
        'GK': ['Jordan Pickford','Dean Henderson','James Trafford'],
        'DEF': ['Reece James','Ezri Konsa','Jarell Quansah','John Stones','Marc Guehi','Dan Burn','Nico OReilly','Djed Spence','Tino Livramento'],
        'MID': ['Declan Rice','Elliot Anderson','Kobbie Mainoo','Jordan Henderson','Morgan Rogers','Jude Bellingham','Eberechi Eze'],
        'FWD': ['Harry Kane','Ivan Toney','Ollie Watkins','Bukayo Saka','Marcus Rashford','Anthony Gordon','Noni Madueke'],
    },
    'Países Baixos': {
        'GK': ['Bart Verbruggen','Mark Flekken','Robin Roefs'],
        'DEF': ['Virgil van Dijk','Jan Paul van Hecke','Nathan Ake','Micky van de Ven','Denzel Dumfries','Jorrel Hato','Jurrien Timber'],
        'MID': ['Frenkie de Jong','Tijjani Reijnders','Justin Kluivert','Quinten Timber','Teun Koopmeiners','Ryan Gravenberch','Marten de Roon','Guus Til','Mats Weiffer'],
        'FWD': ['Cody Gakpo','Donyell Malen','Brian Brobbey','Noa Lang','Memphis Depay','Wout Weghorst','Crysencio Summerville'],
    },
    'Bélgica': {
        'GK': ['Thibaut Courtois','Senne Lammens','Mike Penders'],
        'DEF': ['Timothy Castagne','Zeno Debast','Maxim De Cuyper','Koni De Winter','Brandon Mechele','Thomas Meunier','Nathan Ngoy','Joaquin Seys','Arthur Theate'],
        'MID': ['Kevin De Bruyne','Amadou Onana','Nicolas Raskin','Youri Tielemans','Hans Vanaken','Axel Witsel'],
        'FWD': ['Charles De Ketelaere','Jeremy Doku','Matias Fernandez-Pardo','Romelu Lukaku','Dodi Lukebakio','Diego Moreira','Alexis Saelemaekers','Leandro Trossard'],
    },
    'Noruega': {
        'GK': ['Orjan Haskjold Nyland','Egil Selvik','Sander Tangvik'],
        'DEF': ['Julian Ryerson','Marcus Holmgren Pedersen','David Moller Wolfe','Fredrik Bjorkan','Kristoffer Ajer','Torbjorn Heggem','Leo Skiri Ostigard','Sondre Langas','Henrik Falchener'],
        'MID': ['Martin Odegaard','Sander Berge','Fredrik Aursnes','Patrick Berg','Kristian Thorstvedt','Morten Thorsby','Thelo Aasgaard'],
        'FWD': ['Erling Haaland','Alexander Sorloth','Jorgen Strand Larsen','Antonio Nusa','Oscar Bobb','Andreas Schjelderup','Jens Petter Hauge'],
    },
    'Croácia': {
        'GK': ['Dominik Livakovic','Dominik Kotarski','Ivor Pandur'],
        'DEF': ['Josko Gvardiol','Duje Caleta-Car','Josip Sutalo','Josip Stanisic','Marin Pongracic','Martin Erlic','Luka Vuskovic'],
        'MID': ['Luka Modric','Mateo Kovacic','Mario Pasalic','Nikola Vlasic','Luka Sucic','Martin Baturina','Kristijan Jakic','Petar Sucic','Nikola Moro','Toni Fruk'],
        'FWD': ['Ivan Perisic','Andrej Kramaric','Ante Budimir','Marco Pasalic','Petar Musa','Igor Matanovic'],
    },
    'Estados Unidos': {
        'GK': ['Chris Brady','Matt Freese','Matt Turner'],
        'DEF': ['Max Arfsten','Sergino Dest','Alex Freeman','Mark McKenzie','Tim Ream','Chris Richards','Antonee Robinson','Miles Robinson','Joe Scally','Auston Trusty'],
        'MID': ['Tyler Adams','Sebastian Berhalter','Weston McKennie','Gio Reyna','Cristian Roldan','Malik Tillman'],
        'FWD': ['Brenden Aaronson','Folarin Balogun','Ricardo Pepi','Christian Pulisic','Tim Weah','Haji Wright','Alejandro Zendejas'],
    },
    'Marrocos': {
        'GK': ['Yassine Bounou','Munir Mohamedi','Ahmed Tagnaouti'],
        'DEF': ['Noussair Mazraoui','Anass Salah-Eddine','Youssef Belammari','Nayef Aguerd','Chadi Riad','Issa Diop','Redouane Halhal','Achraf Hakimi','Zakaria El Ouahdi'],
        'MID': ['Samir El Mourabet','Ayyoub Bouaddi','Neil El Aynaoui','Sofyan Amrabat','Azzedine Ounahi','Bilal El Khannouss','Ismael Saibari'],
        'FWD': ['Abdessamad Ezzalzouli','Chemsdine Talbi','Soufiane Rahimi','Ayoub El Kaabi','Brahim Diaz','Yassine Gessime','Ayoub Amaimouni'],
    },
    'Senegal': {
        'GK': ['Edouard Mendy','Mory Diaw','Yehvann Diouf'],
        'DEF': ['Krepin Diatta','Antoine Mendy','Kalidou Koulibaly','El Hadji Malick Diouf','Mamadou Sarr','Moussa Niakhate','Moustapha Mbow','Abdoulaye Seck','Ismail Jakobs','Ilay Camara'],
        'MID': ['Idrissa Gana Gueye','Pape Gueye','Lamine Camara','Habib Diarra','Pathe Ciss','Pape Matar Sarr','Bara Sapoko Ndiaye'],
        'FWD': ['Sadio Mane','Ismaila Sarr','Iliman Ndiaye','Assane Diao','Ibrahim Mbaye','Nicolas Jackson','Bamba Dieng','Cherif Ndiaye'],
    },
    'Equador': {
        'GK': ['Hernan Galindez','Moises Ramirez','Gonzalo Valle'],
        'DEF': ['Piero Hincapie','Willian Pacho','Pervis Estupinan','Felix Torres','Joel Ordonez','Jackson Porozo','Angelo Preciado'],
        'MID': ['Moises Caicedo','Alan Franco','Kendry Paez','Pedro Vite','Jordy Alcivar','Denil Castillo','Yaimar Medina'],
        'FWD': ['Enner Valencia','Kevin Rodriguez','Jordy Caicedo','Nilson Angulo','Anthony Valencia','Jeremy Arevalo'],
    },
    'Colômbia': {
        'GK': ['Camilo Vargas','Alvaro Montero','David Ospina'],
        'DEF': ['Davinson Sanchez','Jhon Lucumi','Yerry Mina','Willer Ditta','Daniel Munoz','Santiago Arias','Johan Mojica','Deiver Machado'],
        'MID': ['Richard Rios','Jefferson Lerma','Kevin Castano','Juan Camilo Portilla','Gustavo Puerta','Jhon Arias','Jorge Carrascal','Juan Fernando Quintero','James Rodriguez','Jaminton Campaz'],
        'FWD': ['Juan Camilo Hernandez','Luis Diaz','Luis Suarez','Carlos Andres Gomez','Jhon Cordoba'],
    },
}

# Rate limiting
req_count = 0
batch_time = time.time()
rate_lock = Lock()

def respect_rate_limit():
    """Respeita rate limit de 10 requisições por 2 segundos."""
    global req_count, batch_time

    with rate_lock:
        req_count += 1
        if req_count >= 10:
            elapsed = time.time() - batch_time
            if elapsed < 2.0:
                time.sleep(2.0 - elapsed)
            req_count = 0
            batch_time = time.time()

def remove_accents(text):
    """Remove acentos de um string."""
    nfd = unicodedata.normalize('NFD', text)
    return ''.join(c for c in nfd if unicodedata.category(c) != 'Mn')

def get_wikipedia_photo(name):
    """Busca foto de um jogador no Wikipedia."""
    base_url = "https://en.wikipedia.org/api/rest_v1/page/summary"

    # Estratégia: tentar nome completo, sobrenome, e versões sem acentos
    terms = [
        name,
        name.split()[-1],  # sobrenome
        remove_accents(name),
        remove_accents(name.split()[-1]),
    ]

    for term in set(terms):  # Remove duplicatas
        try:
            respect_rate_limit()

            url = f"{base_url}/{term.replace(' ', '_')}"
            response = requests.get(url, timeout=3)

            if response.status_code == 200:
                data = response.json()
                if 'thumbnail' in data and data['thumbnail'] and 'source' in data['thumbnail']:
                    return data['thumbnail']['source']
        except Exception:
            pass

    return None

def main():
    # Extrair todos os jogadores
    jogadores = []
    for time in ELENCOS.keys():
        for pos in ['GK', 'DEF', 'MID', 'FWD']:
            for nome in ELENCOS[time].get(pos, []):
                jogadores.append(nome)

    # Remover duplicatas mantendo ordem
    jogadores = list(dict.fromkeys(jogadores))

    print(f"Total de jogadores únicos: {len(jogadores)}")
    print("Iniciando busca no Wikipedia...\n")

    resultado = OrderedDict()
    found = 0

    # Processar em sequencial para respeitar rate limit
    for idx, jogador in enumerate(jogadores, 1):
        pct = (idx * 100) // len(jogadores)
        print(f"\r[{pct}%] {jogador[:40]:<40}", end='', flush=True)

        foto = get_wikipedia_photo(jogador)
        if foto:
            resultado[jogador] = foto
            found += 1

    # Salvar resultado
    output_file = r"C:\Users\Notebook\Documents\projects\bolao-copa-2026\fotos_wikipedia.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(resultado, f, ensure_ascii=False, indent=2)

    # Estatísticas
    print("\n")
    print("=" * 42)
    print(f"Total de jogadores: {len(jogadores)}")
    print(f"Com foto encontrada: {found} ({(found * 100) // len(jogadores)}%)")
    print(f"Resultado salvo em: {output_file}")
    print("=" * 42)

if __name__ == '__main__':
    main()
