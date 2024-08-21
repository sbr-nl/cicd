# CI/CD

In deze repository testen en bouwen we de sbr-nl taxonomy-website.
Diverse taxonomieën  worden als aparte repo ontwikkeld, en elk van deze repo's draagt bij aan de website.
Bij een ping van een van de taxonomieën  worden de tests gestart, en bij succes wordt de site gebouwd.
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
Je kan lokaal nadoen wat we op de server doen (minus publiceren van de website). Daarvoor bestaat het script `scripts/test.sh`. Je moet dit script uitvoeren vanuit de root van het project. Het is noodzakelijk dat je een configuratiebestand aanmaakt in de scripts directory: `scripts/config.sh` met als inhoud `local_taxonomy_dir="${HOME}/develop/taxoos/"` als je je taxonomieën  ontwikkeld in /home/joosterlee/develop/taxoos/jenv, /home/joosterlee/develop/taxoos/rj etc.

Aanroep bijv 'jenv' 

## Testen met verschillende versies van taxonomieën 

Tot nu toe testen we instances tegen taxonomieën  uit dezelfde branch; main, develop, ...
Dat werkt zolang alle taxonomieën  bij elkaar en naast elkaar worden ontwikkeld. Maar, in de praktijk gaan we uiteraard zien dat sommige taxonomieën  veel vaker een nieuwe versie krijgen dan andere. 
Om dit te faciliteren en instances te kunnen testen met een varieteit aan versies is de github action Intgration in CICD uitgebreid met de mogelijkheid om een testconfiguratie op te nemen bij een taxonomie. In die testconfiguratie beschrijf je welke taxonomieën  en welke versies er door Arelle moeten worden geladen om de instance te testen.

Een voorbeeld.
Stel er moet een wijziging worden doorgevoerd in de KVK taxonomie. Dat resulteert in een nieuwe versie voor de KVK taxonomie en die ontwikkelen we in de branch _develop_. De overige taxonomieën  blijven ongewijzigd. Voor het gemak noem ik de nieuwe KVK taxonomie kvk_taxonomy_2025. Die komt naast de kvk_taxonomy_2024 in dezelfde repository. I.e.

    kvk-taxonomie  (repository)
    -- kvk_taxonomy_2024 (taxonomy versioned)
    -- kvk_taxonomy_2025 (taxonomy versioned)
    
Verder zijn de RJ, JenV en IFRS nodig om een instance te kunnen testen. 

Wanneer we niets doen dan zal de Github action beide KVK taxonomieën  laden, naast de eerder genoemde drie ondersteunende taxonomieën . Dat zal leiden tot een conflict tijdens het testen, omdat diverse onderdelen in zowel 2024 als 2025van de KVK voorkomen. 
Dit is het moment dat we een testconfiguratie moeten aanmaken voor de KVK.  Want we willen dat alleen de 2025 versie wordt geladen, en van de overige willen we de stabiele versie gebruiken die al gepubliceerd zijn.

We maken daarvoor een testconfig.yaml bestand aan en plaatsen dat naast de diverse versies in de repository. 


    kvk-taxonomie  (repository)
    -- kvk_taxonomy_2024 (taxonomy versioned)
    -- kvk_taxonomy_2025 (taxonomy versioned)
    -- testconfig.yaml
    
De aanwezigheid van dit bestand zal er voor zorgen dat zowel lokaal als op github er gekeken wordt naar de inhoud van dat bestand, en er vervolgens met de genoemde taxonomieën  getest gaat worden.
Zo'n testconfiguratie ziet er als volgt uit:

    repositories:
      - name: jenv-taxonomie
        package: jenv_taxonomy_2024
        branch: main
      - name: ifrs-taxonomie
        package: ifrs_taxonomy_2024
        branch: develop
      - name: rj-taxonomie
        package: rj_taxonomy_2024
        branch: main

Wanneer we nu een wijziging maken in de KVK taxonomie, dan zal, net als altijd, bij een push naar github, een package van de kvk-taxonomie worden gemaakt. En zal de integratie worden gestart. De integratie ziet het configuratie bestand en zal ipv alle taxonomieën  uit de develop branch de verschillende taxonomieën  (bouwen en) laden volgens de specificatie. Dus in dit geval een JenV versie 2024 uit main, IFRS versie 2024 uit develop en RJ versie 2024 uit main laden.
De testen verlopen verder identiek, alle entrypoints uit, in dit geval KVK-2025 worden aan Arelle aangeboden die controleert of er fouten in de taxonomieën  worden geconstateerd. Als er test-instances bij de taxonomie zjn, dan worden die ook aan Arelle aangeboden, wederom met de genoemde taxonomieën . 

Als alles foutloos verloopt, dan wordt de KVK-2025 tax gepubliceerd op githubpages (in de huidige configuratie). 


