# CI/CD

In deze repository testen en bouwen we de sbr-nl taxonomy-website.
Diverse taxonomieen worden als aparte repo ontwikkeld, en elk van deze repo's draagt bij aan de website.
Bij een ping van een van de taxonomieen worden de tests gestart, en bij succes wordt de site gebouwd.
Die kan op bijv. github-pages gehost worden (poc, deze repo produceert een 'website' die benaderbaar is: https://xiffy.github.io/sbr.nl-web/taxonomies/main/rj_taxonomy_2024.zip, de hele website is een artifact van de publish-website action)

Uitganspunten voor een correcte werking;
Er moet op elke taxonomy repository een secret worden gezet.
Naam: PAT
Inhoud, een fine-grained access token gegenereerd op de volgende manier:

Het token maak je als volgt aan (Web interface):
Klik op je foto of initialen rechtsboven,
Kies settings 
Kies <> Developer options (helemaal onderaan)
Kies Personal Access Token
Kies Fine-grained tokens
Noem hem PAT
Jaartje geldig maken is lui en handig
Kies de juiste repo's (only selected repositories)
- alle taxo's
- cicd
permissies:
- Actions: Read/Write
- Commit statuses: Read/Write
- Contents: Read/Write
- Pull requests: Read/Write

Generate en copy token.

Ga naar de taxonomy/cicd repository en kies settings rechtsboven. Kies in het linker menu "Secrets & Variables" vervolgens "Actions". Maak een Repository secret aan 
PAT, plak het token in de waarde en sla op. 

Deze repo moet minimaal leesrechten hebben op elke repo die een taxonomyPackage aanbiedt

## lokaal testen
Je kan lokaal nadoen wat we op de server doen (minus publiceren van de website). Daarvoor bestaat het script `scripts/test.sh`. Je moet dit script uitvoeren vanuit de root van het project. Het is noodzakelijk dat je een configuratiebestand aanmaakt in de scripts directory: `scripts/config.sh` met als inhoud `local_taxonomy_dir="${HOME}/develop/taxoos/"` als je je taxonomieen ontwikkeld in /home/joosterlee/develop/taxoos/jenv, /home/joosterlee/develop/taxoos/rj etc.

Aanroep bijv 'jenv' 
