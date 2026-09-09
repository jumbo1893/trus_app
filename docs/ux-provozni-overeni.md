# Provozní ověření večera po zápase

Stav: automatické simulace doplněny. Fyzické telefony, skutečný slabý signál a ukončení procesu operačním systémem zde nebyly ověřeny.

## Automatické scénáře

- `beer_draft_test.dart`: soupiska 40 hráčů, zápis piv i panáků, oprava omylu mínusem, návrat do aplikace s konceptem, neúspěšné uložení, opakování, pomalé uložení a dvojí stisk uložení. Změna vzniklá během ukládání musí zůstat neuložená.
- Stejný test: dvě oddělené klientské relace se společnou simulovanou službou si postupně předají zápis. Druhá relace před zapisováním obnoví uložené počty. Nejde o důkaz bezpečnosti souběžného zápisu na skutečném serveru.
- `entry_draft_scope_test.dart`: uložení a obnovení konceptu, oddělení účtů a kontextů, práce se změněným výchozím stavem.
- `history_pagination_test.dart`: připojení starších záznamů, potlačení dvojího načítání, zachování záznamů při výpadku, opakování stejné stránky, odstranění duplicit a ignorování opožděné odpovědi po obnovení historie.
- `trusbot_reading_position_test.dart`: nové zprávy při čtení staršího obsahu nepohnou pohledem; tlačítko přesune na konec; na konci se nové zprávy sledují automaticky; technické výjimky se nezobrazují uživateli.

## Ověření na dvou skutečných telefonech

Použít testovací tým a zápas, alespoň 40 hráčů a dva účty s oprávněním zapisovat. Poznamenat verzi aplikace, serveru a systému obou telefonů.

1. Zapsat účast, góly a asistence. Vrátit se do zápasu a ověřit počty po novém načtení.
2. Vybrat více hráčů, přidat časté i jiné pokuty, opravit jeden omyl. Uložit a ověřit na druhém telefonu.
3. Na prvním telefonu zapsat piva a panáky hráčům na začátku, uprostřed i na konci soupisky. Ověřit stabilní polohu tlačítek po prvním zápisu i dalších změnách.
4. Během rozepsaného zápisu aplikaci odložit, zamknout telefon a vrátit se. Koncept se nesmí ztratit. Potom proces ukončit a aplikaci spustit znovu; ověřit nabídku obnovení a správné přiřazení hráčů a zápasu.
5. Zapnout režim letadlo a zkusit uložit. Nesmí se zobrazit úspěch ani zmizet koncept. Připojení obnovit a znovu uložit; na druhém telefonu ověřit výsledné počty.
6. Na pomalé síti stisknout uložení vícekrát; ověřit jeden požadavek za běžného čekání. Zvlášť otestovat přerušení odpovědi po zápisu na server a opakování po návratu připojení.
7. Po uložení na telefonu A obnovit zápis na B, přidat další pivo a uložit. Znovu obnovit A a porovnat počty. Toto je postupné předání zápisu.
8. Samostatně otestovat souběh: oba telefony načtou stejný stav, A přidá a uloží pivo, B bez obnovy přidá jinému hráči a uloží. Ověřit všechny hráče, ne pouze právě upraveného.
9. V historii zkontrolovat nový zápis, načíst starší, přerušit připojení a zopakovat načítání. Již načtené záznamy musí zůstat viditelné.
10. U TrusBotu odeslat dotaz a během čekání rolovat ke starším zprávám. Příchozí odpověď nesmí přerušit čtení; ověřit tlačítko „Nové zprávy“.

## Neuzavřená závada souběžného zápisu

Serverová metoda `BeerService.processBeer` porovnává a ukládá absolutní počty z klienta. Požadavek neobsahuje očekávanou verzi ani kontrolu původních počtů. Telefon B se zastaralými daty proto může přepsat již uložené změny telefonu A, a to i u hráče, kterého uživatel na B neměnil. Test postupného předání tuto slabinu neřeší. Pro bezpečný souběh je potřeba samostatná změna ukládacího protokolu s kontrolou konfliktů nebo atomickými změnami a identifikací opakovaných požadavků.

## Rozsah historie úkonů

Zdrojem je seznam oznámení, nikoli úplný audit. Ručně volané `NotificationService.addNotification` pokrývá zápisy piv, gólů/asistencí, pokut a vybrané změny zápasů, hráčů, sazebníku a sezon. Zápis závisí na `notifications.enabled`; změny dalších oblastí a automatické procesy nejsou zaručené. Obrazovka tento omezený rozsah vysvětluje. Opraven je chybný titulek při smazání sezony, který dříve tvrdil, že byla přidána.
