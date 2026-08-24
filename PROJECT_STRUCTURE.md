# Project Structure

## 📁 Directory Structure

```
vidhyakandhi_foundation/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── firebase_options.dart     # Firebase configuration
│   ├── models/
│   │   ├── donation_model.dart   # Donation data model
│   │   └── project_model.dart    # Project data model
│   ├── screens/
│   │   ├── main_screen.dart      # Bottom navigation container
│   │   ├── home_screen.dart      # Dashboard with stats
│   │   ├── add_donation_screen.dart  # Donation form
│   │   ├── preview_screen.dart   # Preview before confirmation
│   │   ├── pdf_preview_screen.dart   # PDF preview & share
│   │   └── recent_screen.dart    # Recent donations list
│   ├── services/
│   │   ├── firestore_service.dart    # Firestore operations
│   │   ├── storage_service.dart      # Firebase Storage operations
│   │   └── pdf_service.dart          # PDF generation
│   └── utils/
│       └── number_to_words.dart      # Number to words converter
├── assets/
│   ├── images/                   # Image assets
│   └── logo/                     # Foundation logo (logo.png)
├── pubspec.yaml                  # Dependencies
└── README.md                     # Project documentation
```

## 🔑 Key Features

### 1. Bottom Navigation
- **Home**: Dashboard with statistics
- **FAB (+)**: Add new donation
- **Recent**: List of recent donations

### 2. Home Screen (Dashboard)
- Total Collection (₹)
- Donors Count
- Filters: Daily, Weekly, Monthly, Custom Date Range
- Real-time data from Firestore

### 3. Add Donation Screen
- Donor Name, Phone, PAN, Address
- Project Dropdown (from Firestore)
- Custom Amount option
- Form validation

### 4. Preview Screen
- Shows all donor and donation details
- Edit button (goes back)
- Confirm & Generate PDF button

### 5. PDF Generation
- Auto receipt number
- Foundation logo (if available)
- Donor details
- Donation details
- Amount in words
- 80G tax text
- Professional blue theme

### 6. PDF Preview & Share
- Preview generated PDF
- Share via WhatsApp
- Share via Email
- Share via system share
- Save to Firebase Storage

### 7. Recent Screen
- List of all donations
- Search functionality
- Tap to open PDF
- Shows donor name, amount, date

## 🔥 Firebase Structure

### Firestore Collections

**projects**
```
projects/{projectId}
  - name: String
  - amount: Number
```

**donations**
```
donations/{donationId}
  - donorName: String
  - phone: String
  - pan: String
  - address: String
  - projectName: String
  - amount: Number
  - pdfUrl: String (nullable)
  - createdAt: Timestamp
```

### Storage Structure
```
receipts/
  └── {year}/
      └── {donationId}.pdf
```

## 📱 Screen Flow

1. **Main Screen** → Bottom Navigation
2. **Home** → Dashboard with filters
3. **FAB (+)** → Add Donation Form
4. **Add Donation** → Preview Screen
5. **Preview** → PDF Preview Screen
6. **PDF Preview** → Share/Save options
7. **Recent** → List of donations → PDF view

## 🎨 UI/UX Features

- Material Design 3
- Blue color theme
- Professional card layouts
- Form validation
- Loading indicators
- Error handling
- Pull to refresh
- Search functionality

## 🔧 Dependencies

- `firebase_core`: Firebase initialization
- `cloud_firestore`: Database operations
- `firebase_storage`: File storage
- `pdf`: PDF generation
- `printing`: PDF preview
- `share_plus`: Share functionality
- `url_launcher`: Open URLs
- `provider`: State management
- `intl`: Date/number formatting
