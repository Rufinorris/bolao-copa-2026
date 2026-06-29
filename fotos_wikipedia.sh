#!/bin/bash

# Script para buscar fotos dos 416 jogadores via Wikipedia API
# Rate limit: máximo 10 requisições por 2 segundos

OUTPUT_FILE="C:/Users/Notebook/Documents/projects/bolao-copa-2026/fotos_wikipedia.json"

# Lista de todos os jogadores
JOGADORES=(
  # Brasil
  "Alisson|Brasil" "Ederson|Brasil" "Weverton|Brasil" "Marquinhos|Brasil"
  "Gabriel|Brasil" "Bremer|Brasil" "Ibanez|Brasil" "Leo Pereira|Brasil"
  "Danilo|Brasil" "Alex Sandro|Brasil" "Douglas Santos|Brasil" "Casemiro|Brasil"
  "Bruno Guimaraes|Brasil" "Fabinho|Brasil" "Lucas Paqueta|Brasil"
  "Vinicius Junior|Brasil" "Raphinha|Brasil" "Matheus Cunha|Brasil"
  "Luiz Henrique|Brasil" "Igor Thiago|Brasil" "Endrick|Brasil"
  "Gabriel Martinelli|Brasil" "Rayan|Brasil" "Neymar|Brasil"

  # Argentina
  "Emiliano Martinez|Argentina" "Juan Musso|Argentina" "Geronimo Rulli|Argentina"
  "Leonardo Balerdi|Argentina" "Lisandro Martinez|Argentina" "Facundo Medina|Argentina"
  "Nahuel Molina|Argentina" "Gonzalo Montiel|Argentina" "Nicolas Otamendi|Argentina"
  "Cristian Romero|Argentina" "Nicolas Tagliafico|Argentina"
  "Valentín Barco|Argentina" "Rodrigo De Paul|Argentina" "Enzo Fernandez|Argentina"
  "Giovani Lo Celso|Argentina" "Alexis Mac Allister|Argentina"
  "Exequiel Palacios|Argentina" "Leandro Paredes|Argentina" "Thiago Almada|Argentina"
  "Julian Alvarez|Argentina" "Nicolas Gonzalez|Argentina" "Jose Manuel Lopez|Argentina"
  "Lautaro Martinez|Argentina" "Lionel Messi|Argentina" "Nicolas Paz|Argentina"
  "Giuliano Simeone|Argentina"

  # França
  "Mike Maignan|France" "Robin Risser|France" "Brice Samba|France" "Lucas Digne|France"
  "Malo Gusto|France" "Lucas Hernandez|France" "Theo Hernandez|France"
  "Ibrahima Konate|France" "Jules Kounde|France" "Maxence Lacroix|France"
  "William Saliba|France" "Dayot Upamecano|France" "N'Golo Kante|France"
  "Manu Kone|France" "Adrien Rabiot|France" "Aurelien Tchouameni|France"
  "Warren Zaire-Emery|France" "Maghnes Akliouche|France" "Bradley Barcola|France"
  "Rayan Cherki|France" "Ousmane Dembele|France" "Desire Doue|France"
  "Jean-Philippe Mateta|France" "Kylian Mbappe|France" "Michael Olise|France"
  "Marcus Thuram|France"

  # Espanha
  "Unai Simon|Spain" "David Raya|Spain" "Joan Garcia|Spain" "Aymeric Laporte|Spain"
  "Marc Cucurella|Spain" "Marcos Llorente|Spain" "Eric Garcia|Spain" "Pedro Porro|Spain"
  "Alex Grimaldo|Spain" "Pau Cubarsi|Spain" "Marc Pubill|Spain" "Rodri|Spain"
  "Fabian Ruiz|Spain" "Mikel Merino|Spain" "Pedri|Spain" "Gavi|Spain"
  "Martin Zubimendi|Spain" "Alex Baena|Spain" "Ferran Torres|Spain"
  "Mikel Oyarzabal|Spain" "Dani Olmo|Spain" "Nico Williams|Spain"
  "Lamine Yamal|Spain" "Yeremy Pino|Spain" "Borja Iglesias|Spain"
  "Victor Munoz|Spain"

  # Portugal
  "Diogo Costa|Portugal" "Jose Sa|Portugal" "Rui Silva|Portugal" "Ricardo Velho|Portugal"
  "Diogo Dalot|Portugal" "Matheus Nunes|Portugal" "Nelson Semedo|Portugal"
  "Joao Cancelo|Portugal" "Nuno Mendes|Portugal" "Goncalo Inacio|Portugal"
  "Renato Veiga|Portugal" "Ruben Dias|Portugal" "Tomas Araujo|Portugal"
  "Ruben Neves|Portugal" "Samuel Costa|Portugal" "Joao Neves|Portugal"
  "Vitinha|Portugal" "Bruno Fernandes|Portugal" "Bernardo Silva|Portugal"
  "Joao Felix|Portugal" "Francisco Trincao|Portugal" "Francisco Conceicao|Portugal"
  "Pedro Neto|Portugal" "Rafael Leao|Portugal" "Goncalo Guedes|Portugal"
  "Goncalo Ramos|Portugal" "Cristiano Ronaldo|Portugal"

  # Alemanha
  "Oliver Baumann|Germany" "Manuel Neuer|Germany" "Alexander Nubel|Germany"
  "Waldemar Anton|Germany" "Nathaniel Brown|Germany" "David Raum|Germany"
  "Antonio Rudiger|Germany" "Nico Schlotterbeck|Germany" "Jonathan Tah|Germany"
  "Malick Thiaw|Germany" "Pascal Gross|Germany" "Joshua Kimmich|Germany"
  "Felix Nmecha|Germany" "Aleksandar Pavlovic|Germany" "Angelo Stiller|Germany"
  "Leon Goretzka|Germany" "Florian Wirtz|Germany" "Maximilian Beier|Germany"
  "Kai Havertz|Germany" "Assan Ouedraogo|Germany" "Jamal Musiala|Germany"
  "Leroy Sane|Germany" "Deniz Undav|Germany" "Nick Woltemade|Germany"
  "Jamie Leweling|Germany"

  # Inglaterra
  "Jordan Pickford|England" "Dean Henderson|England" "James Trafford|England"
  "Reece James|England" "Ezri Konsa|England" "Jarell Quansah|England"
  "John Stones|England" "Marc Guehi|England" "Dan Burn|England"
  "Nico OReilly|England" "Djed Spence|England" "Tino Livramento|England"
  "Declan Rice|England" "Elliot Anderson|England" "Kobbie Mainoo|England"
  "Jordan Henderson|England" "Morgan Rogers|England" "Jude Bellingham|England"
  "Eberechi Eze|England" "Harry Kane|England" "Ivan Toney|England"
  "Ollie Watkins|England" "Bukayo Saka|England" "Marcus Rashford|England"
  "Anthony Gordon|England" "Noni Madueke|England"

  # Países Baixos
  "Bart Verbruggen|Netherlands" "Mark Flekken|Netherlands" "Robin Roefs|Netherlands"
  "Virgil van Dijk|Netherlands" "Jan Paul van Hecke|Netherlands" "Nathan Ake|Netherlands"
  "Micky van de Ven|Netherlands" "Denzel Dumfries|Netherlands" "Jorrel Hato|Netherlands"
  "Jurrien Timber|Netherlands" "Frenkie de Jong|Netherlands"
  "Tijjani Reijnders|Netherlands" "Justin Kluivert|Netherlands" "Quinten Timber|Netherlands"
  "Teun Koopmeiners|Netherlands" "Ryan Gravenberch|Netherlands" "Marten de Roon|Netherlands"
  "Guus Til|Netherlands" "Mats Weiffer|Netherlands" "Cody Gakpo|Netherlands"
  "Donyell Malen|Netherlands" "Brian Brobbey|Netherlands" "Noa Lang|Netherlands"
  "Memphis Depay|Netherlands" "Wout Weghorst|Netherlands" "Crysencio Summerville|Netherlands"

  # Bélgica
  "Thibaut Courtois|Belgium" "Senne Lammens|Belgium" "Mike Penders|Belgium"
  "Timothy Castagne|Belgium" "Zeno Debast|Belgium" "Maxim De Cuyper|Belgium"
  "Koni De Winter|Belgium" "Brandon Mechele|Belgium" "Thomas Meunier|Belgium"
  "Nathan Ngoy|Belgium" "Joaquin Seys|Belgium" "Arthur Theate|Belgium"
  "Kevin De Bruyne|Belgium" "Amadou Onana|Belgium" "Nicolas Raskin|Belgium"
  "Youri Tielemans|Belgium" "Hans Vanaken|Belgium" "Axel Witsel|Belgium"
  "Charles De Ketelaere|Belgium" "Jeremy Doku|Belgium" "Matias Fernandez-Pardo|Belgium"
  "Romelu Lukaku|Belgium" "Dodi Lukebakio|Belgium" "Diego Moreira|Belgium"
  "Alexis Saelemaekers|Belgium" "Leandro Trossard|Belgium"

  # Noruega
  "Orjan Haskjold Nyland|Norway" "Egil Selvik|Norway" "Sander Tangvik|Norway"
  "Julian Ryerson|Norway" "Marcus Holmgren Pedersen|Norway" "David Moller Wolfe|Norway"
  "Fredrik Bjorkan|Norway" "Kristoffer Ajer|Norway" "Torbjorn Heggem|Norway"
  "Leo Skiri Ostigard|Norway" "Sondre Langas|Norway" "Henrik Falchener|Norway"
  "Martin Odegaard|Norway" "Sander Berge|Norway" "Fredrik Aursnes|Norway"
  "Patrick Berg|Norway" "Kristian Thorstvedt|Norway" "Morten Thorsby|Norway"
  "Thelo Aasgaard|Norway" "Erling Haaland|Norway" "Alexander Sorloth|Norway"
  "Jorgen Strand Larsen|Norway" "Antonio Nusa|Norway" "Oscar Bobb|Norway"
  "Andreas Schjelderup|Norway" "Jens Petter Hauge|Norway"

  # Croácia
  "Dominik Livakovic|Croatia" "Dominik Kotarski|Croatia" "Ivor Pandur|Croatia"
  "Josko Gvardiol|Croatia" "Duje Caleta-Car|Croatia" "Josip Sutalo|Croatia"
  "Josip Stanisic|Croatia" "Marin Pongracic|Croatia" "Martin Erlic|Croatia"
  "Luka Vuskovic|Croatia" "Luka Modric|Croatia" "Mateo Kovacic|Croatia"
  "Mario Pasalic|Croatia" "Nikola Vlasic|Croatia" "Luka Sucic|Croatia"
  "Martin Baturina|Croatia" "Kristijan Jakic|Croatia" "Petar Sucic|Croatia"
  "Nikola Moro|Croatia" "Toni Fruk|Croatia" "Ivan Perisic|Croatia"
  "Andrej Kramaric|Croatia" "Ante Budimir|Croatia" "Marco Pasalic|Croatia"
  "Petar Musa|Croatia" "Igor Matanovic|Croatia"

  # Estados Unidos
  "Chris Brady|USA" "Matt Freese|USA" "Matt Turner|USA" "Max Arfsten|USA"
  "Sergino Dest|USA" "Alex Freeman|USA" "Mark McKenzie|USA" "Tim Ream|USA"
  "Chris Richards|USA" "Antonee Robinson|USA" "Miles Robinson|USA" "Joe Scally|USA"
  "Auston Trusty|USA" "Tyler Adams|USA" "Sebastian Berhalter|USA"
  "Weston McKennie|USA" "Gio Reyna|USA" "Cristian Roldan|USA"
  "Malik Tillman|USA" "Brenden Aaronson|USA" "Folarin Balogun|USA"
  "Ricardo Pepi|USA" "Christian Pulisic|USA" "Tim Weah|USA" "Haji Wright|USA"
  "Alejandro Zendejas|USA"

  # Marrocos
  "Yassine Bounou|Morocco" "Munir Mohamedi|Morocco" "Ahmed Tagnaouti|Morocco"
  "Noussair Mazraoui|Morocco" "Anass Salah-Eddine|Morocco" "Youssef Belammari|Morocco"
  "Nayef Aguerd|Morocco" "Chadi Riad|Morocco" "Issa Diop|Morocco"
  "Redouane Halhal|Morocco" "Achraf Hakimi|Morocco" "Zakaria El Ouahdi|Morocco"
  "Samir El Mourabet|Morocco" "Ayyoub Bouaddi|Morocco" "Neil El Aynaoui|Morocco"
  "Sofyan Amrabat|Morocco" "Azzedine Ounahi|Morocco" "Bilal El Khannouss|Morocco"
  "Ismael Saibari|Morocco" "Abdessamad Ezzalzouli|Morocco" "Chemsdine Talbi|Morocco"
  "Soufiane Rahimi|Morocco" "Ayoub El Kaabi|Morocco" "Brahim Diaz|Morocco"
  "Yassine Gessime|Morocco" "Ayoub Amaimouni|Morocco"

  # Senegal
  "Edouard Mendy|Senegal" "Mory Diaw|Senegal" "Yehvann Diouf|Senegal"
  "Krepin Diatta|Senegal" "Antoine Mendy|Senegal" "Kalidou Koulibaly|Senegal"
  "El Hadji Malick Diouf|Senegal" "Mamadou Sarr|Senegal" "Moussa Niakhate|Senegal"
  "Moustapha Mbow|Senegal" "Abdoulaye Seck|Senegal" "Ismail Jakobs|Senegal"
  "Ilay Camara|Senegal" "Idrissa Gana Gueye|Senegal" "Pape Gueye|Senegal"
  "Lamine Camara|Senegal" "Habib Diarra|Senegal" "Pathe Ciss|Senegal"
  "Pape Matar Sarr|Senegal" "Bara Sapoko Ndiaye|Senegal" "Sadio Mane|Senegal"
  "Ismaila Sarr|Senegal" "Iliman Ndiaye|Senegal" "Assane Diao|Senegal"
  "Ibrahim Mbaye|Senegal" "Nicolas Jackson|Senegal" "Bamba Dieng|Senegal"
  "Cherif Ndiaye|Senegal"

  # Equador
  "Hernan Galindez|Ecuador" "Moises Ramirez|Ecuador" "Gonzalo Valle|Ecuador"
  "Piero Hincapie|Ecuador" "Willian Pacho|Ecuador" "Pervis Estupinan|Ecuador"
  "Felix Torres|Ecuador" "Joel Ordonez|Ecuador" "Jackson Porozo|Ecuador"
  "Angelo Preciado|Ecuador" "Moises Caicedo|Ecuador" "Alan Franco|Ecuador"
  "Kendry Paez|Ecuador" "Pedro Vite|Ecuador" "Jordy Alcivar|Ecuador"
  "Denil Castillo|Ecuador" "Yaimar Medina|Ecuador" "Enner Valencia|Ecuador"
  "Kevin Rodriguez|Ecuador" "Jordy Caicedo|Ecuador" "Nilson Angulo|Ecuador"
  "Anthony Valencia|Ecuador" "Jeremy Arevalo|Ecuador"

  # Colômbia
  "Camilo Vargas|Colombia" "Alvaro Montero|Colombia" "David Ospina|Colombia"
  "Davinson Sanchez|Colombia" "Jhon Lucumi|Colombia" "Yerry Mina|Colombia"
  "Willer Ditta|Colombia" "Daniel Munoz|Colombia" "Santiago Arias|Colombia"
  "Johan Mojica|Colombia" "Deiver Machado|Colombia" "Richard Rios|Colombia"
  "Jefferson Lerma|Colombia" "Kevin Castano|Colombia" "Juan Camilo Portilla|Colombia"
  "Gustavo Puerta|Colombia" "Jhon Arias|Colombia" "Jorge Carrascal|Colombia"
  "Juan Fernando Quintero|Colombia" "James Rodriguez|Colombia" "Jaminton Campaz|Colombia"
  "Juan Camilo Hernandez|Colombia" "Luis Diaz|Colombia" "Luis Suarez|Colombia"
  "Carlos Andres Gomez|Colombia" "Jhon Cordoba|Colombia"
)

total=${#JOGADORES[@]}
echo "Total de jogadores: $total"
echo "Iniciando busca..."
echo ""

# Objeto JSON
declare -A result

# Contadores
count=0
found=0
reqs=0
batch_start=$(date +%s%N)

# Função para buscar
get_wiki_photo() {
  local name="$1"
  local baseurl="https://en.wikipedia.org/api/rest_v1/page/summary"

  # Tentar nome completo e sobrenome
  for term in "$name" "${name##* }"; do
    # Rate limit
    ((reqs++))
    if [ $reqs -ge 10 ]; then
      now=$(date +%s%N)
      elapsed=$(( (now - batch_start) / 1000000 ))
      if [ $elapsed -lt 2000 ]; then
        sleep 0.$(printf '%03d' $((2000 - elapsed)))
      fi
      reqs=0
      batch_start=$(date +%s%N)
    fi

    url="$baseurl/$(echo "$term" | python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))')"

    response=$(curl -s -m 3 "$url" 2>/dev/null)
    if [ -n "$response" ]; then
      photo=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('thumbnail',{}).get('source',''))" 2>/dev/null)
      if [ -n "$photo" ]; then
        echo "$photo"
        return 0
      fi
    fi
  done

  return 1
}

# Processar cada jogador
for entry in "${JOGADORES[@]}"; do
  name="${entry%|*}"
  ((count++))
  pct=$((count * 100 / total))

  printf "\r[%d%%] %s" "$pct" "$name"

  photo=$(get_wiki_photo "$name")
  if [ -n "$photo" ]; then
    result["$name"]="$photo"
    ((found++))
  fi
done

echo ""
echo ""
echo "=========================================="
echo "Total de jogadores: $total"
echo "Com foto: $found ($((found * 100 / total))%)"
echo "Resultado: $OUTPUT_FILE"
echo "=========================================="

# Salvar JSON
{
  echo "{"
  first=true
  for name in "${!result[@]}"; do
    if [ "$first" = true ]; then
      first=false
    else
      echo ","
    fi
    printf '  "%s": "%s"' "$name" "${result[$name]}"
  done
  echo ""
  echo "}"
} > "$OUTPUT_FILE"
