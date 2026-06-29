# Busca final completa em todos os jogadores
# Estratégia: para cada jogador, tenta nome completo, sobrenome, e variações

$OutputFile = "C:\Users\Notebook\Documents\projects\bolao-copa-2026\fotos_wikipedia_final.json"

# Todos os 414 jogadores
$todos = @(
    'Alisson','Ederson','Weverton','Marquinhos','Gabriel','Bremer','Ibanez','Leo Pereira',
    'Danilo','Alex Sandro','Douglas Santos','Casemiro','Bruno Guimaraes','Fabinho','Lucas Paqueta',
    'Vinicius Junior','Raphinha','Matheus Cunha','Luiz Henrique','Igor Thiago','Endrick',
    'Gabriel Martinelli','Rayan','Neymar','Emiliano Martinez','Juan Musso','Geronimo Rulli',
    'Leonardo Balerdi','Lisandro Martinez','Facundo Medina','Nahuel Molina','Gonzalo Montiel',
    'Nicolas Otamendi','Cristian Romero','Nicolas Tagliafico','Valentín Barco','Rodrigo De Paul',
    'Enzo Fernandez','Giovani Lo Celso','Alexis Mac Allister','Exequiel Palacios','Leandro Paredes',
    'Thiago Almada','Julian Alvarez','Nicolas Gonzalez','Jose Manuel Lopez','Lautaro Martinez',
    'Lionel Messi','Nicolas Paz','Giuliano Simeone','Mike Maignan','Robin Risser','Brice Samba',
    'Lucas Digne','Malo Gusto','Lucas Hernandez','Theo Hernandez','Ibrahima Konate','Jules Kounde',
    'Maxence Lacroix','William Saliba','Dayot Upamecano','NGolo Kante','Manu Kone','Adrien Rabiot',
    'Aurelien Tchouameni','Warren Zaire-Emery','Maghnes Akliouche','Bradley Barcola','Rayan Cherki',
    'Ousmane Dembele','Desire Doue','Jean-Philippe Mateta','Kylian Mbappe','Michael Olise',
    'Marcus Thuram','Unai Simon','David Raya','Joan Garcia','Aymeric Laporte','Marc Cucurella',
    'Marcos Llorente','Eric Garcia','Pedro Porro','Alex Grimaldo','Pau Cubarsi','Marc Pubill',
    'Rodri','Fabian Ruiz','Mikel Merino','Pedri','Gavi','Martin Zubimendi','Alex Baena',
    'Ferran Torres','Mikel Oyarzabal','Dani Olmo','Nico Williams','Lamine Yamal','Yeremy Pino',
    'Borja Iglesias','Victor Munoz','Diogo Costa','Jose Sa','Rui Silva','Ricardo Velho',
    'Diogo Dalot','Matheus Nunes','Nelson Semedo','Joao Cancelo','Nuno Mendes','Goncalo Inacio',
    'Renato Veiga','Ruben Dias','Tomas Araujo','Ruben Neves','Samuel Costa','Joao Neves',
    'Vitinha','Bruno Fernandes','Bernardo Silva','Joao Felix','Francisco Trincao','Francisco Conceicao',
    'Pedro Neto','Rafael Leao','Goncalo Guedes','Goncalo Ramos','Cristiano Ronaldo','Oliver Baumann',
    'Manuel Neuer','Alexander Nubel','Waldemar Anton','Nathaniel Brown','David Raum','Antonio Rudiger',
    'Nico Schlotterbeck','Jonathan Tah','Malick Thiaw','Pascal Gross','Joshua Kimmich','Felix Nmecha',
    'Aleksandar Pavlovic','Angelo Stiller','Leon Goretzka','Florian Wirtz','Maximilian Beier',
    'Kai Havertz','Assan Ouedraogo','Jamal Musiala','Leroy Sane','Deniz Undav','Nick Woltemade',
    'Jamie Leweling','Jordan Pickford','Dean Henderson','James Trafford','Reece James','Ezri Konsa',
    'Jarell Quansah','John Stones','Marc Guehi','Dan Burn','Nico OReilly','Djed Spence',
    'Tino Livramento','Declan Rice','Elliot Anderson','Kobbie Mainoo','Jordan Henderson','Morgan Rogers',
    'Jude Bellingham','Eberechi Eze','Harry Kane','Ivan Toney','Ollie Watkins','Bukayo Saka',
    'Marcus Rashford','Anthony Gordon','Noni Madueke','Bart Verbruggen','Mark Flekken','Robin Roefs',
    'Virgil van Dijk','Jan Paul van Hecke','Nathan Ake','Micky van de Ven','Denzel Dumfries','Jorrel Hato',
    'Jurrien Timber','Frenkie de Jong','Tijjani Reijnders','Justin Kluivert','Quinten Timber','Teun Koopmeiners',
    'Ryan Gravenberch','Marten de Roon','Guus Til','Mats Weiffer','Cody Gakpo','Donyell Malen',
    'Brian Brobbey','Noa Lang','Memphis Depay','Wout Weghorst','Crysencio Summerville','Thibaut Courtois',
    'Senne Lammens','Mike Penders','Timothy Castagne','Zeno Debast','Maxim De Cuyper','Koni De Winter',
    'Brandon Mechele','Thomas Meunier','Nathan Ngoy','Joaquin Seys','Arthur Theate','Kevin De Bruyne',
    'Amadou Onana','Nicolas Raskin','Youri Tielemans','Hans Vanaken','Axel Witsel','Charles De Ketelaere',
    'Jeremy Doku','Matias Fernandez-Pardo','Romelu Lukaku','Dodi Lukebakio','Diego Moreira',
    'Alexis Saelemaekers','Leandro Trossard','Orjan Haskjold Nyland','Egil Selvik','Sander Tangvik',
    'Julian Ryerson','Marcus Holmgren Pedersen','David Moller Wolfe','Fredrik Bjorkan','Kristoffer Ajer',
    'Torbjorn Heggem','Leo Skiri Ostigard','Sondre Langas','Henrik Falchener','Martin Odegaard',
    'Sander Berge','Fredrik Aursnes','Patrick Berg','Kristian Thorstvedt','Morten Thorsby','Thelo Aasgaard',
    'Erling Haaland','Alexander Sorloth','Jorgen Strand Larsen','Antonio Nusa','Oscar Bobb',
    'Andreas Schjelderup','Jens Petter Hauge','Dominik Livakovic','Dominik Kotarski','Ivor Pandur',
    'Josko Gvardiol','Duje Caleta-Car','Josip Sutalo','Josip Stanisic','Marin Pongracic','Martin Erlic',
    'Luka Vuskovic','Luka Modric','Mateo Kovacic','Mario Pasalic','Nikola Vlasic','Luka Sucic',
    'Martin Baturina','Kristijan Jakic','Petar Sucic','Nikola Moro','Toni Fruk','Ivan Perisic',
    'Andrej Kramaric','Ante Budimir','Marco Pasalic','Petar Musa','Igor Matanovic','Chris Brady',
    'Matt Freese','Matt Turner','Max Arfsten','Sergino Dest','Alex Freeman','Mark McKenzie','Tim Ream',
    'Chris Richards','Antonee Robinson','Miles Robinson','Joe Scally','Auston Trusty','Tyler Adams',
    'Sebastian Berhalter','Weston McKennie','Gio Reyna','Cristian Roldan','Malik Tillman','Brenden Aaronson',
    'Folarin Balogun','Ricardo Pepi','Christian Pulisic','Tim Weah','Haji Wright','Alejandro Zendejas',
    'Yassine Bounou','Munir Mohamedi','Ahmed Tagnaouti','Noussair Mazraoui','Anass Salah-Eddine',
    'Youssef Belammari','Nayef Aguerd','Chadi Riad','Issa Diop','Redouane Halhal','Achraf Hakimi',
    'Zakaria El Ouahdi','Samir El Mourabet','Ayyoub Bouaddi','Neil El Aynaoui','Sofyan Amrabat',
    'Azzedine Ounahi','Bilal El Khannouss','Ismael Saibari','Abdessamad Ezzalzouli','Chemsdine Talbi',
    'Soufiane Rahimi','Ayoub El Kaabi','Brahim Diaz','Yassine Gessime','Ayoub Amaimouni','Edouard Mendy',
    'Mory Diaw','Yehvann Diouf','Krepin Diatta','Antoine Mendy','Kalidou Koulibaly','El Hadji Malick Diouf',
    'Mamadou Sarr','Moussa Niakhate','Moustapha Mbow','Abdoulaye Seck','Ismail Jakobs','Ilay Camara',
    'Idrissa Gana Gueye','Pape Gueye','Lamine Camara','Habib Diarra','Pathe Ciss','Pape Matar Sarr',
    'Bara Sapoko Ndiaye','Sadio Mane','Ismaila Sarr','Iliman Ndiaye','Assane Diao','Ibrahim Mbaye',
    'Nicolas Jackson','Bamba Dieng','Cherif Ndiaye','Hernan Galindez','Moises Ramirez','Gonzalo Valle',
    'Piero Hincapie','Willian Pacho','Pervis Estupinan','Felix Torres','Joel Ordonez','Jackson Porozo',
    'Angelo Preciado','Moises Caicedo','Alan Franco','Kendry Paez','Pedro Vite','Jordy Alcivar',
    'Denil Castillo','Yaimar Medina','Enner Valencia','Kevin Rodriguez','Jordy Caicedo','Nilson Angulo',
    'Anthony Valencia','Jeremy Arevalo','Camilo Vargas','Alvaro Montero','David Ospina','Davinson Sanchez',
    'Jhon Lucumi','Yerry Mina','Willer Ditta','Daniel Munoz','Santiago Arias','Johan Mojica',
    'Deiver Machado','Richard Rios','Jefferson Lerma','Kevin Castano','Juan Camilo Portilla','Gustavo Puerta',
    'Jhon Arias','Jorge Carrascal','Juan Fernando Quintero','James Rodriguez','Jaminton Campaz',
    'Juan Camilo Hernandez','Luis Diaz','Luis Suarez','Carlos Andres Gomez','Jhon Cordoba'
)

Write-Host "Processando $($todos.Count) jogadores"

$resultado = @{}
$reqs = 0
$batchTime = Get-Date

for ($i = 0; $i -lt $todos.Count; $i++) {
    $nome = $todos[$i]
    $pct = [int](($i / $todos.Count) * 100)

    if ($pct % 10 -eq 0) {
        Write-Host -NoNewline "`r[$pct%] Processando... encontradas: $(($resultado.Count))"
    }

    # Rate limit
    $reqs++
    if ($reqs -ge 10) {
        $elapsed = ((Get-Date) - $batchTime).TotalMilliseconds
        if ($elapsed -lt 2000) {
            Start-Sleep -Milliseconds ([int](2000 - $elapsed))
        }
        $reqs = 0
        $batchTime = Get-Date
    }

    # Tentar buscar
    try {
        $url = "https://en.wikipedia.org/api/rest_v1/page/summary/$([System.Uri]::EscapeDataString($nome))"
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        $data = $resp.Content | ConvertFrom-Json

        if ($data.thumbnail -and $data.thumbnail.source) {
            $resultado[$nome] = $data.thumbnail.source
        }
    } catch {}
}

# Salvar
$json = $resultado | ConvertTo-Json -Depth 10
Set-Content -Path $OutputFile -Value $json -Encoding UTF8

$taxa = [int](($resultado.Count / $todos.Count) * 100)
Write-Host ""
Write-Host "=========================================="
Write-Host "Busca completa!"
Write-Host "Total: $($todos.Count) jogadores"
Write-Host "Fotos encontradas: $($resultado.Count)"
Write-Host "Taxa de sucesso: $taxa%"
Write-Host "Arquivo: $OutputFile"
Write-Host "=========================================="

# Copiar para fotos_wikipedia.json
Copy-Item $OutputFile "C:\Users\Notebook\Documents\projects\bolao-copa-2026\fotos_wikipedia.json" -Force
Write-Host "Resultado principal atualizado!"
