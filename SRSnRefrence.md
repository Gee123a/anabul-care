//
//  SRSnRefrence.md
//  anabul-care
//
//  Created by Stevanus Ivan Santoso on 21/05/26.
//

DOCUMENT 2: SOFTWARE REQUIREMENTS SPECIFICATION (SRS)
System Name: Paws & Learn Ecosystem (AnabulCare Solution)
Document Target: Engineering Team Validation / AI Context Boundary Constraint
Standards Version: 2026.1.0 (IEEE 830 Adaptation)
1. Introduction
1.1 Purpose
This document establishes the binding functional, performance, data, and architectural requirements for the multi-platform application Paws & Learn. This runtime configuration manages health tracks, proactive climate safety metrics, voice-driven ingredient security, and localized map lookups for domestic pets in Indonesia.
1.2 Project Scope
The software system comprises a core iOS application target, an iPadOS visual dashboard target, a watchOS tracking application, a WidgetKit UI extension framework, an App Intents system search extension, and an ActivityKit Live Activity rendering pipeline. The architecture targets young or inexperienced pet owners, specifically focusing on mitigating accidental toxicity poisoning, heat stroke in tropical urban settings, and the high rate of pet abandonment caused by a lack of basic care knowledge.
1.3 Definitions, Acronyms, and Abbreviations
Anabul: Anak Bulu (Indonesian colloquial term for companion animals).
Puskeswan: Pusat Kesehatan Hewan (Government-subsidized, low-cost community veterinary clinics in Indonesia).
RER: Resting Energy Requirement.
MER: Maintenance Energy Requirement.
SSoT: Single Source of Truth database state.
SwiftData: Apple's native data persistence framework.
ActivityKit: Apple framework for managing Live Activities.
WeatherKit: Apple framework for retrieving weather data.
1.4 Core Architectural Invariants
Offline-First Priority: All toxicity matching, daily schedule evaluations, and behavioral tips must run completely locally on the device. Network connectivity is permitted only for live environmental queries via WeatherKit and MapKit.
Local Data Pipeline (Harvest & Seed Method): Global web APIs (API Ninjas, Open Food Facts, The Dog/Cat API, Encyclopedia of Life) are restricted to pre-development asset preparation. The production application must run off a compiled static JSON reference array (MetadataRegistry.json) stored directly in the main app bundle. On the first launch, this asset seeds the local SwiftData framework container.
Strict Species Constraints: Any configuration, calculation, or display state containing species data types must reject any string outside the explicit enumeration values: dog, cat, or hamster.
Indonesian Context Alignment: All localized safety alerts, medical records, and spatial queries must use Indonesian standards (e.g., matching common food terms like bawang, mapping Puskeswan clinics, and recognizing regional tropical climate zones).
2. Overall Description
2.1 Product Perspective
The system functions as a highly integrated, local-first application layer interacting directly with native Apple system frameworks:
SwiftData Context: Manages cross-target transactional data synchronization.
CoreSpotlight & App Intents: Projects internal reference nodes directly into the iOS search engine UI.
WeatherKit Core: Continuously evaluates real-world environmental risks without requiring custom cloud infrastructure.
MapKit Service: Leverages point-of-interest databases to find local resources for free.
2.2 Product Functions
The software must provide six primary execution modules:
Automated care routines visualizable through system widgets.
Hands-free voice verification for ingredient toxicity.
Geo-fenced map routing to nearby subsidized veterinary help and boarding.
Independent physical activity session logging via a companion watchOS application.
Persistent countdown tracking on the Lock Screen and Dynamic Island.
Local background climate scanning with threshold alerts.
Bite-sized daily behavioral tips and tricks.
2.3 User Characteristics
The target user profile is defined as a digital-native, urban pet owner in Indonesia (predominantly living in metropolitan apartments or kost rooms in cities like Jakarta and Surabaya). The user has limited experience with companion animal care, is highly vulnerable to financial anxiety regarding private clinic pricing, and frequently handles food preparation with messy or occupied hands.
2.4 Constraints
Hardware Constraint: The system must execute cleanly on iOS 17+, iPadOS 17+, and watchOS 10+.
Network Dependency: The system must execute safety validations and schedule logic with zero network connectivity.
API Restriction: Third-party web scrapers or unpaid public APIs must not be introduced into live app operations.
3. Specific Requirements
3.1 Functional Requirements (FR)
FR-1: Intelligent Care Scheduling Engine
FR-1.1 Input Processing: The system MUST force the user to select from explicit options (dog, cat, hamster) during setup. It must also require a valid numeric weight in kilograms and an onboarding date of birth.
FR-1.2 Calculation Scheduling: The system SHALL compute daily energy targets instantly using the formulas defined in Document 1: The Math Calculation Engine Specifications.
FR-1.3 Widget Delivery: The system SHALL run WidgetKit background operations to refresh schedule timeline displays on the iOS Home Screen and iPadOS Lock Screen every 4 hours.
FR-2: Zero-Friction Safety Queries
FR-2.1 Text Search Matching: The system SHALL index all local Indonesian strings present in the ToxicityDatabase into the native iOS system lookup via CoreSpotlight.
FR-2.2 Voice Input Execution: The system MUST expose an AppIntent endpoint accessible via Siri voice commands. If a user queries "Apakah [Item] aman untuk [Spesies]?", the intent must parse the match and return a system-spoken color-coded response card directly within the system search interface.
FR-3: Puskeswan & Pet Care Radar
FR-3.1 Location Ingestion: The system SHALL use CoreLocation to request the device's precise latitude and longitude coordinates.
FR-3.2 Local Mapping Queries: The system SHALL generate an internal MKLocalSearch.Request using the current GPS coordinate as the geographic center point.
FR-3.3 Keyphrase Restrictions: The search engine MUST restrict its natural language query parameter strings to these specific tokens: "Pet Hotel", "Penitipan Hewan", "Puskeswan", "Klinik Hewan".
FR-3.4 Render Constraints: Results MUST be displayed on an interactive SwiftUI map layer limited to a bounding travel circle of 10 kilometers around the user's location.
FR-4: Frictionless Action Logging & Active Play Sessions
FR-4.1 Companion Wrist Logging: The watchOS target SHALL display single-tap configuration interfaces that append a new ActivityLog node directly to the shared SwiftData context.
FR-4.2 Live Activity Initialization: Starting an indoor play session MUST create an ActivityKit lifestyle loop with a predefined, fixed countdown timer of 20 minutes.
FR-4.3 Multi-Surface Persistence: The live progress bar and countdown timer MUST stay visible and update smoothly on the iOS Lock Screen and the Dynamic Island without requiring the main app to stay open in the foreground.
FR-5: Tropical Hydration & Climate Safety Alerts
FR-5.1 Periodic Background Scans: The system SHALL wake up background workers periodically to poll local outdoor temperatures via WeatherKit.
FR-5.2 Conditional Threshold Alerts: The system MUST evaluate the active profile's species type against the recorded local temperature based on the thresholds defined in Document 1: Precise Technical Environment Thresholds:
Condition A: Species is dog or cat, and the temperature crosses $\ge 34.0^\circ\text{C}$.
Condition B: Species is hamster, and the temperature crosses $\ge 26.0^\circ\text{C}$.
FR-5.3 Push Dispatch: If either condition evaluates to true, the system MUST immediately send a high-priority local UserNotification warning the owner to refresh water bowls or turn on ventilation.
FR-6: "Anabul" Daily Tidbits (Micro-Learning Engine)
FR-6.1 Data Injection: The system SHALL read daily, bite-sized care tips and behavioral hacks out of the bundled reference catalog.
FR-6.2 Research Application: To combat animal abandonment trends (referencing Chen dkk., 2026 and Rafly dkk., 2023), the display routine MUST prioritize age-specific behavioral guidance tips when an active pet profile enters a transition milestone (e.g., reaching 7+ years for senior dogs).
3.2 Non-Functional Requirements (NFR)
NFR-1: Performance & Execution Latency
Latency Limit: All local safety lookups processed via AppIntents or CoreSpotlight MUST return their search results within 200 milliseconds of invocation.
Memory Efficiency: Background synchronization services for SwiftData must use a clean memory management loop, keeping resource usage low so the main iOS system never kills the widget process.
NFR-2: High Availability & Offline Execution
Network Independence: The application MUST perform its core functions (including toxicity checks, metabolic math calculations, care notifications, and trivia updates) even when the device is completely offline or in Airplane Mode.
NFR-3: Local Privacy Boundaries
Data Isolation: The application MUST store all pet profiles, household logging trends, and device location coordinates within the sandboxed local storage layer of the device. The system is strictly forbidden from uploading user location histories or metrics to external servers.
ARCHITECTURE FRAMEWORK SYNC (AI VERIFICATION GUIDE)
       
graph TD
    %% Base Data Layers
    subgraph Local_Static_Bundle [App Main Bundle: Read-Only]
        A[MetadataRegistry.json]
    end

    subgraph Core_Persistence_Layer [Shared Sandbox Container]
        B[(SwiftData Store: ModelContext)]
    end

    %% Sync Pipeline
    A -->|Seed Store on Initial Launch| B

    %% Shared Compilation Core
    subgraph Shared_Framework_Target [Shared Domain Framework Core]
        B <--> C[PetProfile & ActivityLog Models]
    end

    %% Multi-Platform Main Application Targets
    subgraph Client_Applications [Foreground User Targets]
        D[iOS Main Application]
        E[iPadOS Management Dashboard]
        F[watchOS Companion Tracker]
    end
    
    C <--> D
    C <--> E
    C <--> F

    %% Native Extension Ecosystem
    subgraph System_Extensions [Background & System Integrations]
        G[App Intents Extension: Siri & Spotlight]
        H[WidgetKit Extension: Home & Lock UI]
        I[ActivityKit Engine: Dynamic Island]
    end

    C -.->|Read Local Matrix| G
    C -.->|Fetch Timelines| H
    C -.->|Maintain State| I

    %% System API Integration Nodes
    subgraph Native_Apple_APIs [Hardware / Cloud Environment APIs]
        J[WeatherKit API]
        K[MapKit & CoreLocation API]
    end

    D & E & I <--->|Poll Live Data| J
    D & E <--->|Query Spatial Index| K

    %% Styling for AI Path Differentiation
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style J fill:#f96,stroke:#333,stroke-width:1px
    style K fill:#f96,stroke:#333,stroke-width:1px


This structural blueprint defines the entire scope and functional boundaries of the application. Any automated system, coding model, or development process interacting with this codebase must adhere strictly to these rules, schemas, and framework configurations. It must reject any additions or expansions that fall outside this explicit product specification.

{
  "DataPipeline": {
    "Phase_1_Ingestion": [
      { "Source": "https://api.api-ninjas.com/v1/dogs", "Extracted_Attributes": ["min_weight", "max_weight", "grooming"] },
      { "Source": "https://api.api-ninjas.com/v1/cats", "Extracted_Attributes": ["min_weight", "max_weight", "playfulness"] },
      { "Source": "https://api.api-ninjas.com/v1/animals?name=hamster", "Extracted_Attributes": ["characteristics.weight", "characteristics.temperament"] },
      { "Source": "https://world.openfoodfacts.org/api", "Extracted_Attributes": ["ingredients_text_id", "ingredients_text_en"] }
    ],
    "Phase_2_Aggregation_Script": {
      "Runtime_Language": "Python 3.11 / Swift Script",
      "Operations": [
        "Averages weights to calculate foundational baseline kilograms",
        "Normalizes numeric scale metrics from 1-5 to localized app calendar parameters"
      ],
      "Manual_Injection_Dictionary": {
        "Target": "indonesian_toxic_hazards",
        "Payload": ["bawang", "cokelat", "anggur", "ksilitol", "biji apel", "almond"]
      }
    },
    "Phase_3_Compilation_Target": {
      "Output_File": "MetadataRegistry.json",
      "Path": "/ProjectDir/MainBundle/Assets/"
    }
  }
}


 Thermal_Monitoring_Rules Engine:
  Evaluation_Trigger: "Periodic Background App Refresh / WeatherKit Update Loop"
  Species_Condition_1:
    Type: "dog"
    Type_Alternative: "cat"
    Safety_Parameters:
      Lower_Boundary_Celsius: -99.0
      Upper_Safe_Celsius: 33.9
      Trigger_Alert_Celsius: 34.0
      Target_Lethal_Celsius: 38.0
    System_Action:
      Notification_Priority: "Standard"
      Alert_Title: "Periksa Air Minum Anabul!"
      Alert_Body: "Suhu sekitar mencapai {Current_Temp}°C. Pastikan wadah air minum terisi penuh dan sirkulasi udara ruangan berjalan baik."

  Species_Condition_2:
    Type: "hamster"
    Safety_Parameters:
      Lower_Boundary_Celsius: 15.0
      Upper_Safe_Celsius: 25.9
      Trigger_Alert_Celsius: 26.0
      Target_Lethal_Celsius: 28.0
    System_Action:
      Notification_Priority: "High / Critical Emergency Override"
      Alert_Title: "Peringatan Stres Panas Hamster!"
      Alert_Body: "Suhu ruangan terdeteksi kritis ({Current_Temp}°C). Hamster tidak memiliki kelenjar keringat; segera nyalakan pendingin ruangan atau pindahkan kandang ke area sejuk."

