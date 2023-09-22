
class AppBarTitleManager {
  String appBarTitle = "Trusí appka";

  String setAppBarTitle(int index) {
      switch (index) {
        case 0:
          appBarTitle = "Trusí appka";
          break;
        case 1:
          appBarTitle = "Přidání pokut";
          break;
        case 3:
          appBarTitle = "Statistiky pokut/piv";
          break;
        case 4:
          appBarTitle = "Přidat hráče";
          break;
        case 5:
          appBarTitle = "Upravit hráče";
          break;
        case 6:
          appBarTitle = "Sezony";
          break;
        case 7:
          appBarTitle = "Přidat sezonu";
          break;
        case 8:
          appBarTitle = "Upravit sezonu";
          break;
        case 9:
          appBarTitle = "Zápasy";
          break;
        case 10:
          appBarTitle = "Přidat zápas";
          break;
        case 11:
          appBarTitle = "Upravit zápas";
          break;
        case 12:
          appBarTitle = "Pokuty";
          break;
        case 13:
          appBarTitle = "Přidat pokutu";
          break;
        case 14:
          appBarTitle = "Upravit pokutu";
          break;
        case 15:
          appBarTitle = "Přidat pokutu hráči";
          break;
        case 16:
          appBarTitle = "Přidat pokutu více hráčům";
          break;
        case 17:
          appBarTitle = "Přidat pivo";
          break;
        case 18:
          appBarTitle = "Hráči";
          break;
        case 19:
          appBarTitle = "Seznam PKFL zápasů";
          break;
        case 20:
          appBarTitle = "Statistika PKFL";
          break;
        case 21:
          appBarTitle = "Tabulka PKFL";
          break;
        case 22:
          appBarTitle = "Statistika gólů/asistencí";
          break;
        case 23:
          appBarTitle = "Notifikace";
          break;
        case 24:
          appBarTitle = "Nastavení uživatelů";
          break;
        case 25:
          appBarTitle = "Info o aplikaci";
          break;
      }
      return appBarTitle;
  }
}
