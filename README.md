# Sanctions

An official mobile application for looking up persons and entities on United Nations and national sanctions lists.

The app is intended for authorised use in the Kingdom of Bahrain. It follows the visual language of the Ministry of Interior / Bahrain Police: navy, gold, white surfaces, and a restrained institutional layout. Arabic is the default language. English is available throughout.

This is a lookup tool. It is not a case-management system, and it is not a substitute for the official source of a listing.

## Purpose

Authorised users can:

- Sign in with their civil identity details
- Browse United Nations sanctions lists (individuals and entities)
- Browse the national sanctions list (persons and entities)
- Search loaded records by name, identifier, or reference
- Open a record to review identity, aliases, documents, dates, and related particulars
- Switch between Arabic and English, including right-to-left layout for Arabic

The app reminds users that information should always be verified against the official source before any legal or compliance decision.

## Who it is for

The application is for users who need to check whether a person or organisation appears on an official sanctions list, using credentials recognised by the Ministry of Interior.

It is not a public directory. Access starts at login.

## How it works

### Sign in

The user enters:

- CPR (9-digit personal number)
- CPR expiry date
- Block number
- Bahrain mobile number (+973)

The app authenticates against the Ministry of Interior API. After a successful login, a six-digit OTP step is shown. Once verified, the user reaches the main application.

A secondary **Biometric Login** control is present on the login screen. It is a user preference only at this stage. Device biometric authentication is not connected yet. If biometric login has not been enabled after signing in, the app explains that it must be turned on from inside the app.

### Main navigation

After login, three destinations are available:

| Tab | What it opens |
| --- | --- |
| Home | Official lookup hub: choose United Nations or National |
| UN | United Nations lists: Individuals or Entities |
| National | National lists: Persons or Entities |

### Searching lists

Each list loads records from the official API in pages and can be searched locally on the records already loaded. Typical search fields include name, ID, nationality, recorded name, or reference number, depending on the list.

Selecting a row opens a dossier-style details screen. United Nations records are refreshed by ID where the API supports it. National records show the particulars returned with the list.

Lists can be pulled to refresh. Further pages load as the user scrolls.

### Account and session

The header keeps the language toggle and notifications. Logout is not on the header. A three-dot menu opens an account panel that shows:

- The signed-in CPR
- Enable / disable biometric login (UI preference)
- Logout, as a separate destructive action with confirmation

Logout returns the user to the login screen.

Notifications are an in-app inbox surface. They are not connected to a server feed yet.

## Lists in more detail

### United Nations

- **Individuals** — people listed on official UN sanctions lists, with names, aliases, nationality, dates and places of birth, documents, addresses, comments, and related identifiers.
- **Entities** — companies, organisations, and other listed entities, with names, aliases, addresses, and related particulars.

### National

- **Persons** — persons included in the national sanctions list, with Arabic and English names where provided, nationality, dates, documents, and listing notes.
- **Entities** — entities included in the national sanctions list, with recorded names and related particulars.

## Languages

The application supports Arabic and English.

- Arabic uses a right-to-left layout.
- Identifiers such as CPR remain left-to-right so they stay readable.
- The language control is available on login and in the header after sign-in.

## What the app does not do

- It does not replace the official published list for legal or compliance decisions.
- It does not add, remove, or edit sanctions records.
- Search is performed on records already loaded in the current list, not as a separate server-wide search.
- Device biometric authentication and secure credential storage are not implemented yet. Enabling biometric login only records a preference in the current session.
- Notifications are not delivered from a backend.

## Important notice

Information shown in the app should always be verified against the official source before making a legal or compliance decision.
