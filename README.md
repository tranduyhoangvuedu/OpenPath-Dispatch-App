# OpenPath Dispatch 

A B2B crowdsourced mapping and logistics platform designed to track real-time mobility barriers, construction, and accessibility hazards. Developed by Nexus Corp.

## Current Market 
* **Beta Testing Phase:** Ho Chi Minh City, Vietnam 
* **Target Expansion:** Portland, Oregon (May 2027)

## Tech Stack
* **Frontend:** Flutter (Web/Mobile)
* **Backend:** Supabase (PostgreSQL, Row Level Security)
* **Mapping Engine:** OpenStreetMap via flutter_map

## Architecture Overview
OpenPath utilizes a CRUD architecture to allow delivery fleets and couriers to drop location-based obstacle pins (e.g., Blocked Sidewalks, Construction). The data is instantly synchronized globally via Supabase, bypassing standard mapping limitations to provide hyper-accurate, last-mile routing.
