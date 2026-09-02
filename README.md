# RaceDay Event Management System

## Project Overview

RaceDay is a full-stack web-based event management system designed specifically for the South African road running, walking, and cycling community. The platform allows Event Organisers to create and manage events, categories, and participant results, while Participants can browse upcoming events, enrol, and track their personal performance history.

## System Roles

- **Organiser**: Can create, edit, and delete events, manage categories, capture participant results, and view all enrolments
- **Participant**: Can create an account, browse events, enrol by selecting a category, view own enrolments, and track personal results

## Documentation

All planning documents are in the `/docs` folder:

- `ERD.pdf` - Entity Relationship Diagram
- `API_Endpoint_Plan.pdf` - RESTful API endpoint specifications
- `RaceDay_DatabaseScript.sql` - SQL Server database creation script

## CI/CD Status

![CI/CD Build](https://github.com/YOUR-USERNAME/RaceDay/actions/workflows/ci.yml/badge.svg)


## Setup Instructions

1. Clone the repository
2. Open `docs/RaceDay_DatabaseScript.sql` in SSMS
3. Execute the script to create the database
4. Verify all tables and seed data are created
