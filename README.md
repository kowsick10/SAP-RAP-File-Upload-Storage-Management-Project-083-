
# SAP RAP: File Upload & Storage Management (Project 083)

An advanced implementation of the **ABAP RESTful Application Programming Model (RAP)** for handling **Large Objects (LOBs)**.

This project demonstrates how to build a **custom File Store** that supports **uploading, downloading, and automatically managing file metadata** (size, MIME type, etc.) using an **Unmanaged RAP Implementation**.

---

# 🚀 Features

### File Streaming

Upload and download **PDFs, Images, and Documents** directly through **SAP Fiori Elements UI**.

### Auto-Calculated Metadata

The system automatically calculates:

* File Size (in bytes)
* MIME Type
* Uploaded By
* Uploaded On

All metadata is handled through **ABAP backend logic**.

### Unmanaged RAP Logic

Provides **full control over database operations** using:

* Custom **Transactional Buffer Class**
* RAP **Saver Class**

### Authorization Handling

Two levels of security are implemented:

**Global Authorization**

* Controls whether a user can access the **Create Upload** action.

**Instance Authorization**

* Controls **Edit and Delete permissions** for individual file records.

### Fiori Elements UI

Optimized UI using **Metadata Extensions**:

* Search Filters
* Logical Field Grouping
* Responsive Object Page Layout

### UUID Based File IDs

Every uploaded file receives a **unique 16-byte HEX UUID** automatically generated in the backend.

---

# 🛠 Technology Stack

| Layer                | Technology                                       |
| -------------------- | ------------------------------------------------ |
| Programming Language | ABAP (Cloud / ABAP 7.5+)                         |
| Data Modeling        | CDS Views (Core Data Services)                   |
| Framework            | ABAP RAP (RESTful Application Programming Model) |
| UI                   | SAP Fiori Elements                               |
| Service Protocol     | OData V2                                         |
| Database             | SAP HANA                                         |

---

# 📁 Project Structure

The project follows the **standard SAP BTP / S4HANA object hierarchy**.

## Business Services

```
ZUI_FILE_STORE_083
```

Service Definition

```
ZUI_FILE_STORE_V2_083
```

OData V2 Service Binding

---

## Core Data Services

```
ZI_FILE_STORE_083
```

Root CDS View Entity for Data Modeling

```
ZME_FILE_STORE_083
```

Metadata Extension for UI annotations.

---

## Behavior Definitions

```
ZI_FILE_STORE_083
```

Defines RAP operations:

* Create
* Update
* Delete

Includes **Authorization Master Logic**.

---

## Source Code Library

```
ZBP_I_FILE_STORE_083
```

Behavior Implementation Class
This class contains the **main business logic** of the application.

---

## Dictionary Objects

```
ZFILE_STORE_083
```

Transparent database table used to store files and metadata.

---

# ⚙️ Installation & Setup

## 1. Create Database Table

Create the following table:

```
ZFILE_STORE_083
```

Fields:

| Field Name | Description        |
| ---------- | ------------------ |
| FILE_ID    | UUID Primary Key   |
| FILE_NAME  | File Name          |
| MIME_TYPE  | File MIME Type     |
| FILE_SIZE  | File Size in Bytes |
| FILE_DATA  | LOB Binary Data    |
| CREATED_BY | Uploaded User      |
| CREATED_AT | Upload Timestamp   |

---

## 2. Create CDS View

Enable **Large Object semantics** in CDS.

```abap
@Semantics.largeObject: {
   mimeType: 'MimeType',
   fileName: 'FileName',
   contentDispositionPreference: #ATTACHMENT
}
file_data as FileData;
```

This annotation enables **file upload and download functionality in Fiori**.

---

## 3. Behavior Definition

Use **Unmanaged Implementation** with strict mode.

```
unmanaged implementation in class ZBP_I_FILE_STORE_083
strict ( 2 );
```

Operations supported:

* Create
* Update
* Delete

---

## 4. Behavior Implementation

Implement logic inside:

```
ZBP_I_FILE_STORE_083
```

Key methods include:

* Create
* Update
* Delete
* Authorization checks
* Metadata calculation

---

## ⚠ Important RAP Rule

Direct database operations are **not allowed during the interaction phase**.

The following operations will cause a runtime dump:

```
BEHAVIOR_ILLEGAL_STATEMENT
```

Forbidden statements:

```
INSERT
UPDATE
DELETE
COMMIT WORK
```

---

## Correct Approach

Use a **Local Buffer Class**.

### Process Flow

```
Create/Update Request
        ↓
Data stored in Local Buffer
        ↓
SAVE Method of Saver Class
        ↓
Database INSERT/UPDATE
```

This ensures **RAP transactional consistency**.

---

# 🔑 Authorization Logic

The project implements **two-level authorization checks**.

### Global Authorization

Controls if the user can perform **Create operations**.

Example use case:

```
Only Admin or Authorized Users can upload files
```

---

### Instance Authorization

Controls access to **existing file records**.

Example rules:

* Only the **owner** can edit the file
* Only **admins** can delete files

---

# 📝 Usage

### Step 1

Open the **Service Binding**

```
ZUI_FILE_STORE_V2_083
```

---

### Step 2

Click **Preview** for the entity:

```
FileStore
```

---

### Step 3

Click **Create**

Upload any file:

* PDF
* Image
* Document

---

### Step 4

Click **Save**

The system automatically fills:

* Uploaded On
* Uploaded By
* File Size
* MIME Type

---

### Step 5

Download files using the **Download link** in the List Report.

---

# 📌 Supported File Types

The application supports uploading:

* PDF
* JPG / PNG
* Word Documents
* Excel Files
* Other Binary Documents

---

# 🎯 Learning Outcomes

This project demonstrates:

* RAP **Unmanaged Implementation**
* **File handling with LOBs**
* **Transactional Buffer Pattern**
* **Fiori Elements integration**
* **Authorization in RAP**
* **OData V2 service exposure**


