# Flower Recognizer

**Flower Recognizer** este o aplicație mobilă inteligentă dezvoltată cu scopul de a recunoaște și clasifica automat specii de flori, direct pe dispozitivele mobile (Edge AI). 

Acest proiect reprezintă o lucrare de licență realizată în cadrul **Universității de Vest din Timișoara, Facultatea de Informatică**, propunând o arhitectură hibridă *offline-first*. Aplicația rezolvă problema dependenței de conexiunea la internet în medii naturale izolate (păduri, zone montane), rulând inferența vizuală complet local, în timp ce serviciile cloud și API-urile externe sunt utilizate ca extensii opționale pentru îmbogățirea experienței utilizatorului.

---

## Facilități Principale

* **Identificare Offline (Live & Galerie):** Analiza instantanee a imaginilor preluate direct din fluxul camerei sau din galeria telefonului, fără a necesita conexiune la internet.
* **Mecanism Defensiv (OOD):** Implementarea unui prag strict de încredere de **95%**. Orice predicție sub acest nivel este marcată ca „Necunoscută”, prevenind halucinațiile modelului în cazul scanării unor obiecte non-florale.
* **Ierbar Digital (Colecție Personală):** Un spațiu dedicat unde utilizatorii își pot salva istoricul florilor identificate. Imaginile sunt stocate inovator ca șiruri `Base64` direct în documentele din baza de date, asigurând disponibilitatea lor chiar și offline (via Firebase Cache).
* **Sfaturi de Îngrijire Generate de AI:** Integrare cu **Groq API** (folosind modelul *LLaMA-3.3-70b-versatile*) pentru a furniza utilizatorilor sfaturi personalizate de îngrijire (udare, lumină, temperatură, sol, toxicitate animale) structurate în format JSON.
* **Descrieri Enciclopedice Botanice:** Integrare cu **Wikipedia REST API** pentru preluarea de descrieri științifice și informații generale, mapate automat pe limba română.

---

## Arhitectură și Tehnologii

Sistemul este divizat logic în trei zone de responsabilitate:

### 1. Zona Client (Presentation Layer)
* **Flutter SDK & Dart:** Framework cross-platform pentru o interfață fluidă, bazată pe o temă întunecată (Dark Mode) și elemente vizuale de tip *Bottom Sheet* pentru afișarea rezultatelor.
* **State Management & UI:** Implementarea unei navigări intuitive (Scanare, Ierbar, Profil).

### 2. Zona de Procesare Locală (Edge AI)
* **TensorFlow Lite (TFLite):** Modelul antrenat este cuantizat la precizie pe 8 biți (Int8) și redus la o dimensiune de doar **4.76 MB**, rulând inferența direct pe procesorul telefonului mobil.
* **Python, Keras, scikit-learn:** Utilizate pentru antrenamentul rețelei neuronale, augmentarea datelor, echilibrarea claselor (*class weights*) și preprocesare.

### 3. Zona de Cloud și API-uri Externe
* **Firebase Authentication:** Flux de logare securizat prin Email/Parolă și Google Sign-In.
* **Cloud Firestore:** Bază de date NoSQL unde sunt stocate metadatele și imaginile codificate în format `Base64`.
* **Groq API & Wikipedia API:** Pentru preluarea dinamică a contextului botanic.

---

## Modelul de Machine Learning (EfficientNetB0)

Sistemul utilizează rețeaua neuronală convoluțională **EfficientNetB0**, optimizată prin tehnica de *Transfer Learning*. În faza preliminară, arhitectura a fost testată comparativ cu *MobileNetV2*, demonstrând o acuratețe superioară și o stabilitate excelentă a funcției de eroare.

### Setul de Date și Clasele Suportate
Modelul a fost antrenat pe un set masiv de **17.199 de imagini** și este capabil să recunoască **19 specii distincte**:
*Astilbe, Bellflower, Black-eyed Susan, Calendula, California Poppy, Carnation, Common Daisy, Coreopsis, Daffodil, Dandelion, Iris, Lavender, Lotus, Magnolia, Orchid, Rose, Sunflower, Tulip, Water Lily*.

### Performanța Modelului
* **Acuratețe Validare (Validation Accuracy):** 89.92%
* **Acuratețe Testare (Test Accuracy):** 85.00%
* **F1-Score General:** 0.85
* **Eroare (Validation Loss):** 0.3771 (fără semne de overfitting)

---

## Ecranele Aplicației
| Scanare Live (Camera) | Rezultate și Sfaturi AI | Ierbarul Digital (Colecția) |
|:---:|:---:|:---:|
| <img src="https://github.com/alexadrianilie1/plant-identifier/blob/main/assets/screens/scan_screen.jpeg" width="200"> | <img src="https://github.com/alexadrianilie1/plant-identifier/blob/main/assets/screens/detail_screen.jpeg" width="200"> | <img src="https://github.com/alexadrianilie1/plant-identifier/blob/main/assets/screens/herbar_screen.png" width="200"> |

---

## Instalare și Configurare (Local Development)

### Precondiții
* SDK-ul Flutter instalat (versiunea recomandată 3.x+).
* Un cont [Firebase](https://console.firebase.google.com/) activ.
* O cheie API de la [Groq](https://console.groq.com/).
* În cazul rulării aplicației pe un emulator este necesară crearea acestuia în prealabil.

### Pași de instalare
1. **Clonează repository-ul:**
   ```bash
   git clone [https://github.com/alexadrianilie1/plant-identifier](https://github.com/alexadrianilie1/plant-identifier)
   cd plant-identifier

2. **Instalează dependențele:**
    ```bash
    flutter pub get

3. **Configurează Firebase:**
    Adaugă fișierul google-services.json pentru Android în folderul android/app/.
    Asigură-te că Cloud Firestore și Authentication (Email/Google) sunt active în consola Firebase.

4. **Variabile de Mediu:**
    Creează un fișier .env în rădăcina proiectului și adaugă cheia pentru asistentul AI:
    ```bash
    GROQ_KEY=cheia_ta_aici

5. **Rulează aplicația pe un dispozitiv fizic sau emulator:**
    ```bash
    flutter run

## Pași de rulare pe emulator ##

1. **Verifică disponibilitatea emulatorului:**
    ```bash
    flutter emulators
2. **Lansarea emulatorului:**
    ```bash
    flutter emulators --launch <emulator_id>
3. **Rulează aplicația:**
    ```bash
    flutter run


