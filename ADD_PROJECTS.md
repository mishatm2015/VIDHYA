# How to Add Projects to Firebase

## Step-by-Step Guide

### 1. Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **vidhyakaandhi-foundation**
3. Navigate to **Firestore Database**

### 2. Create Projects Collection
1. Click **Start collection** (if `projects` collection doesn't exist)
2. Collection ID: `projects`
3. Click **Next**

### 3. Add Each Project Document

For each project, create a document with these fields:

#### Document Structure:
- **Document ID**: Auto-generate (or use a custom ID like `project1`, `project2`, etc.)
- **Fields**:
  - `name` (String) - Project name
  - `amount` (Number) - Project cost ⚠️ **IMPORTANT: Use Number type, NOT String!**

**⚠️ Common Mistake:** Make sure `amount` is set as **Number** type, not String. If you see quotes around the number in Firebase, it's a String and needs to be changed to Number.

#### Example Projects to Add:

1. **Project 1:**
   - name: `FEED A FAMILY FOR 2 MONTH`
   - amount: `7950`

2. **Project 2:**
   - name: `EDUCATION 2 GIRL CHILD FOR 1 YEAR`
   - amount: `19900`

3. **Project 3:**
   - name: `NUTRITION FOOD FOR 1 ORPHAN CHILD`
   - amount: `2850`

4. **Project 4:**
   - name: `EDUCATION 1 GIRL CHILD FOR 6 MONTHS`
   - amount: `6900`

5. **Project 5:**
   - name: `FEED A FAMILY FOR 2 WEEK`
   - amount: `2550`

6. **Project 6:**
   - name: `EDUCATION 1 GIRL CHILD 1 YEAR`
   - amount: `9950`

7. **Project 7:**
   - name: `FEED A CHILD FOR A MONTH`
   - amount: `2975`

8. **Project 8:**
   - name: `FULL DAY MEAL FOR 400 CHILDREN`
   - amount: `68500`

9. **Project 9:**
   - name: `ABANDONED CHILD FULL CARE 1 YEAR`
   - amount: `72000`

10. **Project 10:**
    - name: `HYGENIE KIT FOR 6 PEOPLE`
    - amount: `1850`

11. **Project 11:**
    - name: `FEED 3 STREET CHILDREN FOR A MONTH`
    - amount: `9905`

12. **Project 12:**
    - name: `INFANT GIRL CHILD SUPPORT 1 YEAR`
    - amount: `46800`

13. **Project 13:**
    - name: `FEED 10 OLD AGED PEOPLE FOR 1 YEAR`
    - amount: `295000` (2.95 LAKHS = 295000)

14. **Project 14:**
    - name: `FEED 10 OLD AGED PEOPLE FOR 1 MONTH`
    - amount: `29500`

### 4. Quick Add Method (Using Firebase Console)

1. Go to **Firestore Database** → **Data** tab
2. Click **Start collection** (if first time)
3. Collection ID: `projects`
4. Click **Next**
5. For each project:
   - Click **Add field**
   - Field name: `name`, Type: `string`, Value: `[Project Name]`
   - Click **Add field**
   - Field name: `amount`, Type: `number`, Value: `[Amount]`
   - Click **Save**
   - Click **Add document** to add next project

### 5. Verify Projects

After adding projects:
1. You should see all projects in the `projects` collection
2. Each document should have `name` and `amount` fields
3. Restart the app or refresh the donation form
4. Projects should now appear in the dropdown

### 6. Troubleshooting

**If projects don't appear:**
1. Check Firestore rules allow read access (see `FIRESTORE_RULES.md`)
2. Make sure you're logged in (authentication required)
3. Check console for errors
4. Try refreshing the app
5. Verify collection name is exactly `projects` (lowercase)

### 7. Firestore Rules Check

Make sure your Firestore rules allow reading projects:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /projects/{projectId} {
      allow read: if true; // Public read
      allow write: if request.auth != null; // Only authenticated users
    }
  }
}
```

## Quick Copy-Paste Format

When adding in Firebase Console, use this format:

**Field 1:**
- Name: `name`
- Type: `string`
- Value: `FEED A CHILD FOR A MONTH`

**Field 2:**
- Name: `amount`
- Type: `number` ⚠️ **Must be Number type, NOT string!**
- Value: `2975` (no quotes - if you see quotes, it's wrong!)

**⚠️ Fix Existing Projects:**
If you already added projects with `amount` as String:
1. Click on the document
2. Click on the `amount` field
3. Change type from `string` to `number`
4. Enter the number value (without quotes)
5. Click Save

Repeat for each project!
