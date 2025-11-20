# Strona Koła Naukowego Bioinformatyki

Strona Koła hostowana jest na serwerze **mimsrv**. Na podstawie znajdujących się tam plików generowana jest statyczna strona Hugo.  
Hugo to framework zalecany przez Laboratorium Komputerowe MIMUW.

---

## Modyfikacja contentu na stronie

W celu modyfikacji strony, <u>zamiast logować się na serwer, wystarczy dodać zmiany na tym repozytorium GitHub</u>.

### Dodanie artykułu w aktualnościach
Każdy artykuł, to osobny plik **.md** w katalogu `content/aktualnosci`. Standardowy format artykułu wymaga nagłówka:

    +++
    title = "<tytuł artykułu>"
    date = "<YYYY-MM-DD>"        # wymagana do ustalenia kolejności artykułów
    draft = "<true/false>"       # określa czy artykuł jest w wersji roboczej (false publikuje artykuł na stronie)
    tags = ["nauka", "zabawa"]   # tagi, których użycie nie jest na razie zaimplementowane
    summary = ""                 # tekst wyświetlany na liście artykułów
    image = "<images/ścieżka/do/pliku>" # głowny baner artykułu - plik należy umieścić w static/images, ścieżka zaczyna się od "images/"
    +++
    
Resztę treści wystarczy napisać w standardowym formacie Markdown.

---

## Synchronizacja repozytorium z serwerem

Repozytorium jest automatycznie synchronizowane z serwerem za pomocą **GitHub Actions**.  
Konfiguracja GitHub Actions opiera się na:

### • Pliku `deploy.yml` (`.github/workflows/deploy.yml`)
Główny plik odpowiedzialny za:

1. Wykrywanie zmian w repozytorium  
2. Generowanie nowej strony Hugo  
3. Wysyłanie nowej strony na serwer **mimsrv**

W przypadku zmiany domeny należy zmodyfikować ostatnią linijkę (`:~/knbioinf.mimuw.edu.pl`).

### • Sekretach GitHub Actions  
Przechowywane w:  
https://github.com/kn-bioinf/knb-web/settings/secrets/actions

Sekrety:

- **DEPLOY_USER**, **DEPLOY_HOST** – user@host do połączeń SSH  
- **DEPLOY_KEY** – klucz SSH, który powinien znajdować się w `authorized_keys` na serwerze mimsrv

### • Pliku `hugo.toml`
Konfiguruje stronę Hugo.  
Zawiera parametr `baseURL` - w przypadku zmiany domeny należy zaktualizować jego wartość.

---

## Logowanie na serwer SSH

Logowanie możliwe jest za pomocą kluczy SSH. W celu pozyskania klucza i dalszych informacji należy zgłosić się do ostatniego zarządzającego stroną **[Stanisław Gołębiewski]** lub opiekuna Koła **[Aleksander Jankowski]**.
