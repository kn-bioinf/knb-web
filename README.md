# Strona Koła Naukowego Bioinformatyki

Strona Koła hostowana jest na serwerze **mimsrv**. Na podstawie znajdujących się tam plików generowana jest statyczna strona Hugo.  
Hugo to framework zalecany przez Laboratorium Komputerowe MIMUW.

---

## Modyfikacja contentu na stronie

W celu modyfikacji strony, zamiast logować się na serwer, wystarczy dodać zmiany na tym repozytorium GitHub.

### Dodanie artykułu w aktualnościach
Każdy artykuł to plik **.md** w katalogu `content/aktualnosci`. Standardowy format artykułu wymaga nagłówka:
    +++
    title = "<tytuł artykułu>"
    date = "<YYYY-MM-DD>"        # wymagana do ustalenia kolejności artykułów
    draft = "<true/false>"
    tags = ["nauka", "zabawa"]
    summary = ""                 # tekst wyświetlany na liście artykułów
    image = "<ścieżka/do/pliku>" # pliki w static/images, ścieżka zaczyna się od "images/"
    +++

    Resztę treści wystarczy napisać w standardowym formacie Markdown

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
Zawiera parametr `baseURL` — w przypadku zmiany domeny należy zaktualizować jego wartość.

---

## Logowanie na serwer SSH

Logowanie możliwe jest za pomocą kluczy SSH przez `ssh knbioinf@mimsrv.mimuw.edu.pl`
W celu pozyskania klucza należy zgłosić się do ostatniego zarządzającego stroną **[Stanisław Gołębiewski]**.
