# Gold Mobile Backend API Documentation

## Tech Stack
- **Framework**: NestJS
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT (Access + Refresh tokens)
- **File Upload**: Multer/MinIO for images
- **SMS**: SMS provider integration for OTP

---

## Database Schema (Prisma)

```prisma
// schema.prisma

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

// ============================================
// ADMIN & ROLES
// ============================================

// Admin foydalanuvchilar
model Admin {
  id          String     @id @default(uuid())
  email       String     @unique
  password    String     // Hashed
  name        String
  role        AdminRole  @default(BRANCH_ADMIN)
  
  // Branch admin uchun
  branchId    String?
  branch      Branch?    @relation(fields: [branchId], references: [id])
  
  isActive    Boolean    @default(true)
  lastLoginAt DateTime?
  
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt
  
  // Activity logs
  activityLogs AdminActivityLog[]
  
  @@index([email])
  @@index([branchId])
}

enum AdminRole {
  SUPER_ADMIN      // Full system access
  BRANCH_ADMIN     // Specific branch access
  MANAGER          // View only + reports
  SUPPORT          // Handle user issues
}

// Admin activity logs
model AdminActivityLog {
  id        String   @id @default(uuid())
  adminId   String
  admin     Admin    @relation(fields: [adminId], references: [id])
  action    String   // CREATE_PRODUCT, UPDATE_ORDER, etc.
  entity    String   // Product, Order, User
  entityId  String?
  details   Json?    // Additional details
  ipAddress String?
  createdAt DateTime @default(now())
  
  @@index([adminId, createdAt])
}

// ============================================
// BRANCHES & LOCATIONS
// ============================================
model Branch {
  id        String   @id @default(uuid())
  name      String
  address   String
  phone     String
  latitude  Float?
  longitude Float?
  isActive  Boolean  @default(true)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  products  Product[]
  orders    Order[]
  admins    Admin[]  // Branch adminlar
  requests  UserVerificationRequest[]
  
  @@index([isActive])
}

// Foydalanuvchilar
model User {
  id                String    @id @default(uuid())
  phoneNumber       String    @unique
  name              String?
  dateOfBirth       DateTime?
  passportSeries    String?
  passportNumber    String?
  pinfl             String?   @unique
  
  // Verification
  isVerified        Boolean   @default(false)
  faceImageUrl      String?
  passportImageUrl  String?
  verifiedAt        DateTime?
  
  // Credit limit
  creditLimit       Float?
  usedLimit         Float     @default(0)
  limitExpiryDate   DateTime?
  
  // Auth
  refreshToken      String?
  lastLoginAt       DateTime?
  
  createdAt         DateTime  @default(now())
  updatedAt         DateTime  @updatedAt
  
  favorites         Favorite[]
  cartItems         CartItem[]
  orders            Order[]
  verificationRequests UserVerificationRequest[]
  
  @@index([phoneNumber])
  @@index([pinfl])
}

// User verification requests (ariza)
model UserVerificationRequest {
  id               String                @id @default(uuid())
  userId           String
  user             User                  @relation(fields: [userId], references: [id])
  
  branchId         String
  branch           Branch                @relation(fields: [branchId], references: [id])
  
  name             String
  dateOfBirth      DateTime
  passportSeries   String
  passportNumber   String
  pinfl            String
  faceImageUrl     String
  passportImageUrl String
  
  requestedLimit   Float                 @default(20000000) // 20M
  status           VerificationStatus    @default(PENDING)
  
  // Admin review
  reviewedBy       String?
  reviewedAt       DateTime?
  reviewNotes      String?
  approvedLimit    Float?
  
  createdAt        DateTime              @default(now())
  updatedAt        DateTime              @updatedAt
  
  @@index([userId, status])
  @@index([branchId, status])
  @@index([status])
}

enum VerificationStatus {
  PENDING
  APPROVED
  REJECTED
  MORE_INFO_NEEDED
}

// Kategoriyalar
model Category {
  id          String    @id @default(uuid())
  name        String
  nameUz      String
  nameRu      String
  icon        String?
  sortOrder   Int       @default(0)
  isActive    Boolean   @default(true)
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  
  products    Product[]
}

// Mahsulotlar
model Product {
  id          String   @id @default(uuid())
  name        String
  nameUz      String
  nameRu      String
  description String?
  descriptionUz String?
  descriptionRu String?
  
  price       Float
  discount    Float?   @default(0)
  
  material    String
  weight      Float
  
  images      String[] // Array of image URLs
  
  inStock     Boolean  @default(true)
  stockQuantity Int    @default(0)
  
  rating      Float    @default(0)
  reviewCount Int      @default(0)
  
  categoryId  String
  category    Category @relation(fields: [categoryId], references: [id])
  
  branchId    String
  branch      Branch   @relation(fields: [branchId], references: [id])
  
  isActive    Boolean  @default(true)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  favorites   Favorite[]
  cartItems   CartItem[]
  orderItems  OrderItem[]
}

// Sevimlilar
model Favorite {
  id        String   @id @default(uuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  productId String
  product   Product  @relation(fields: [productId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
  
  @@unique([userId, productId])
}

// Savat
model CartItem {
  id        String   @id @default(uuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  productId String
  product   Product  @relation(fields: [productId], references: [id], onDelete: Cascade)
  quantity  Int      @default(1)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  @@unique([userId, productId])
}

// Buyurtmalar
model Order {
  id              String      @id @default(uuid())
  orderNumber     String      @unique
  
  userId          String
  user            User        @relation(fields: [userId], references: [id])
  
  branchId        String
  branch          Branch      @relation(fields: [branchId], references: [id])
  
  totalAmount     Float
  
  // Installment details
  isInstallment   Boolean     @default(false)
  monthlyPayment  Float?
  totalMonths     Int?
  paidMonths      Int         @default(0)
  remainingAmount Float?
  nextPaymentDate DateTime?
  interestRate    Float?
  
  status          OrderStatus @default(PENDING)
  
  deliveryAddress String?
  deliveryPhone   String?
  notes           String?
  
  createdAt       DateTime    @default(now())
  updatedAt       DateTime    @updatedAt
  
  items           OrderItem[]
  payments        Payment[]
}

enum OrderStatus {
  PENDING
  CONFIRMED
  PROCESSING
  DELIVERED
  CANCELLED
}

// Buyurtma mahsulotlari
model OrderItem {
  id        String  @id @default(uuid())
  orderId   String
  order     Order   @relation(fields: [orderId], references: [id], onDelete: Cascade)
  productId String
  product   Product @relation(fields: [productId], references: [id])
  quantity  Int
  price     Float   // Price at time of order
  
  createdAt DateTime @default(now())
}

// To'lovlar
model Payment {
  id            String        @id @default(uuid())
  orderId       String
  order         Order         @relation(fields: [orderId], references: [id])
  amount        Float
  paymentDate   DateTime
  paymentMethod PaymentMethod @default(CASH)
  status        PaymentStatus @default(PENDING)
  transactionId String?
  notes         String?
  
  createdAt     DateTime      @default(now())
  updatedAt     DateTime      @updatedAt
}

enum PaymentMethod {
  CASH
  CARD
  BANK_TRANSFER
  CLICK
  PAYME
}

enum PaymentStatus {
  PENDING
  COMPLETED
  FAILED
  REFUNDED
}

// OTP codes
model OtpCode {
  id          String   @id @default(uuid())
  phoneNumber String
  code        String
  expiresAt   DateTime
  isUsed      Boolean  @default(false)
  createdAt   DateTime @default(now())
  
  @@index([phoneNumber, code])
}
```

---

## API Endpoints

### 1. Admin Authentication (`/api/admin/auth`)

#### POST `/api/admin/auth/login`
Admin login
```typescript
Request Body:
{
  email: string
  password: string
}

Response:
{
  accessToken: string
  refreshToken: string
  admin: {
    id: string
    email: string
    name: string
    role: 'SUPER_ADMIN' | 'BRANCH_ADMIN' | 'MANAGER' | 'SUPPORT'
    branchId: string | null
    branch: {
      id: string
      name: string
    } | null
  }
}
```

#### POST `/api/admin/auth/logout`
Admin logout
```typescript
Headers:
Authorization: Bearer <accessToken>

Response:
{
  success: boolean
}
```

#### GET `/api/admin/auth/me`
Get current admin info
```typescript
Headers:
Authorization: Bearer <accessToken>

Response:
{
  id: string
  email: string
  name: string
  role: string
  branchId: string | null
  branch: {...} | null
}
```

---

### 2. Admin Management (`/api/admin/admins`) - Super Admin Only

#### GET `/api/admin/admins`
List all admins
```typescript
Headers:
Authorization: Bearer <accessToken>

Query Params:
- page?: number (default: 1)
- limit?: number (default: 20)
- role?: AdminRole
- branchId?: string
- search?: string

Response:
{
  data: Admin[]
  pagination: {
    total: number
    page: number
    limit: number
    totalPages: number
  }
}
```

#### POST `/api/admin/admins`
Create new admin
```typescript
Request Body:
{
  email: string
  password: string
  name: string
  role: 'SUPER_ADMIN' | 'BRANCH_ADMIN' | 'MANAGER' | 'SUPPORT'
  branchId?: string // Required if role is BRANCH_ADMIN
}

Response:
{
  id: string
  email: string
  name: string
  role: string
  branchId: string | null
}
```

#### PATCH `/api/admin/admins/:id`
Update admin
```typescript
Request Body:
{
  name?: string
  role?: AdminRole
  branchId?: string
  isActive?: boolean
}

Response: Admin
```

#### DELETE `/api/admin/admins/:id`
Delete admin
```typescript
Response:
{
  success: boolean
}
```

---

### 3. Branch Management (`/api/admin/branches`)

#### GET `/api/admin/branches`
List all branches
```typescript
Headers:
Authorization: Bearer <accessToken>

Query Params:
- page?: number
- limit?: number
- isActive?: boolean

Response:
{
  data: Branch[]
  pagination: {...}
}
```

#### POST `/api/admin/branches`
Create new branch (Super Admin only)
```typescript
Request Body:
{
  name: string
  address: string
  phone: string
  latitude?: number
  longitude?: number
}

Response: Branch
```

#### PATCH `/api/admin/branches/:id`
Update branch
```typescript
Request Body:
{
  name?: string
  address?: string
  phone?: string
  latitude?: number
  longitude?: number
  isActive?: boolean
}

Response: Branch
```

#### GET `/api/admin/branches/:id/stats`
Branch statistics
```typescript
Response:
{
  totalProducts: number
  activeProducts: number
  totalOrders: number
  pendingOrders: number
  totalRevenue: number
  monthlyRevenue: number
}
```

---

### 4. User Verification Requests (`/api/admin/verification-requests`)

#### GET `/api/admin/verification-requests`
List verification requests
```typescript
Headers:
Authorization: Bearer <accessToken>

Query Params:
- page?: number
- limit?: number
- status?: 'PENDING' | 'APPROVED' | 'REJECTED' | 'MORE_INFO_NEEDED'
- branchId?: string // Branch admin sees only their branch

Response:
{
  data: [
    {
      id: string
      userId: string
      user: {
        id: string
        phoneNumber: string
        name: string
      }
      branchId: string
      branch: {
        id: string
        name: string
      }
      name: string
      dateOfBirth: string
      passportSeries: string
      passportNumber: string
      pinfl: string
      faceImageUrl: string
      passportImageUrl: string
      requestedLimit: number
      status: string
      reviewedBy: string | null
      reviewedAt: string | null
      reviewNotes: string | null
      approvedLimit: number | null
      createdAt: string
    }
  ]
  pagination: {...}
}
```

#### GET `/api/admin/verification-requests/:id`
Get single request details
```typescript
Response: UserVerificationRequest with full details
```

#### PATCH `/api/admin/verification-requests/:id/approve`
Approve verification request
```typescript
Request Body:
{
  approvedLimit: number // Can be less than requested
  reviewNotes?: string
}

Response:
{
  success: boolean
  request: UserVerificationRequest
  user: User // Updated with creditLimit and isVerified
}
```

#### PATCH `/api/admin/verification-requests/:id/reject`
Reject verification request
```typescript
Request Body:
{
  reviewNotes: string // Required
}

Response:
{
  success: boolean
  request: UserVerificationRequest
}
```

#### PATCH `/api/admin/verification-requests/:id/request-more-info`
Request more information
```typescript
Request Body:
{
  reviewNotes: string // What info is needed
}

Response:
{
  success: boolean
  request: UserVerificationRequest
}
```

---

### 5. Product Management (`/api/admin/products`)

#### GET `/api/admin/products`
List products
```typescript
Query Params:
- page?: number
- limit?: number
- branchId?: string // Branch admin sees only their products
- categoryId?: string
- isActive?: boolean
- search?: string

Response:
{
  data: Product[]
  pagination: {...}
}
```

#### POST `/api/admin/products`
Create new product
```typescript
Request Body (multipart/form-data):
{
  name: string
  nameUz: string
  nameRu: string
  description?: string
  descriptionUz?: string
  descriptionRu?: string
  price: number
  discount?: number
  material: string
  weight: number
  categoryId: string
  branchId: string // Branch admin auto-filled
  stockQuantity: number
  images: File[] // Multiple images
}

Response: Product
```

#### PATCH `/api/admin/products/:id`
Update product
```typescript
Request Body (multipart/form-data):
{
  name?: string
  nameUz?: string
  nameRu?: string
  description?: string
  descriptionUz?: string
  descriptionRu?: string
  price?: number
  discount?: number
  material?: string
  weight?: number
  categoryId?: string
  stockQuantity?: number
  inStock?: boolean
  isActive?: boolean
  images?: File[] // New images
  removeImages?: string[] // URLs to remove
}

Response: Product
```

#### DELETE `/api/admin/products/:id`
Delete product (soft delete - isActive = false)
```typescript
Response:
{
  success: boolean
}
```

---

### 6. Order Management (`/api/admin/orders`)

#### GET `/api/admin/orders`
List orders
```typescript
Query Params:
- page?: number
- limit?: number
- branchId?: string // Branch admin sees only their orders
- status?: OrderStatus
- isInstallment?: boolean
- startDate?: string
- endDate?: string
- search?: string // Order number, user phone

Response:
{
  data: Order[]
  pagination: {...}
}
```

#### GET `/api/admin/orders/:id`
Get order details
```typescript
Response:
{
  id: string
  orderNumber: string
  user: {
    id: string
    phoneNumber: string
    name: string
  }
  branch: {
    id: string
    name: string
  }
  totalAmount: number
  isInstallment: boolean
  monthlyPayment: number | null
  totalMonths: number | null
  paidMonths: number
  remainingAmount: number | null
  nextPaymentDate: string | null
  interestRate: number | null
  status: string
  deliveryAddress: string | null
  deliveryPhone: string | null
  notes: string | null
  items: OrderItem[]
  payments: Payment[]
  createdAt: string
}
```

#### PATCH `/api/admin/orders/:id/status`
Update order status
```typescript
Request Body:
{
  status: 'PENDING' | 'CONFIRMED' | 'PROCESSING' | 'SHIPPED' | 'DELIVERED' | 'CANCELLED' | 'REFUNDED'
  notes?: string
}

Response: Order
```

#### POST `/api/admin/orders/:id/cancel`
Cancel order
```typescript
Request Body:
{
  reason: string
}

Response:
{
  success: boolean
  order: Order
  refundedAmount: number // If installment, refund remaining limit
}
```

---

### 7. Payment Management (`/api/admin/payments`)

#### GET `/api/admin/payments`
List payments
```typescript
Query Params:
- page?: number
- limit?: number
- branchId?: string
- orderId?: string
- status?: 'PENDING' | 'COMPLETED' | 'FAILED' | 'REFUNDED'
- startDate?: string
- endDate?: string

Response:
{
  data: Payment[]
  pagination: {...}
}
```

#### PATCH `/api/admin/payments/:id/confirm`
Confirm manual payment
```typescript
Request Body:
{
  notes?: string
}

Response: Payment
```

---

### 8. Dashboard & Analytics (`/api/admin/dashboard`)

#### GET `/api/admin/dashboard/stats`
Dashboard statistics
```typescript
Query Params:
- branchId?: string // Branch admin auto-filtered
- startDate?: string
- endDate?: string

Response:
{
  // Orders
  totalOrders: number
  pendingOrders: number
  completedOrders: number
  cancelledOrders: number
  
  // Revenue
  totalRevenue: number
  monthlyRevenue: number
  dailyRevenue: number
  
  // Users
  totalUsers: number
  verifiedUsers: number
  newUsersToday: number
  
  // Products
  totalProducts: number
  lowStockProducts: number
  
  // Installments
  activeInstallments: number
  overduePayments: number
  
  // Verification Requests
  pendingRequests: number
  
  // Branch specific (if branchId provided)
  branchStats?: {
    products: number
    orders: number
    revenue: number
  }
}
```

#### GET `/api/admin/dashboard/revenue-chart`
Revenue chart data
```typescript
Query Params:
- period: 'week' | 'month' | 'year'
- branchId?: string

Response:
{
  labels: string[] // Dates
  data: number[] // Revenue amounts
}
```

#### GET `/api/admin/dashboard/top-products`
Top selling products
```typescript
Query Params:
- limit?: number (default: 10)
- branchId?: string

Response:
{
  products: [
    {
      id: string
      name: string
      image: string
      totalSold: number
      revenue: number
    }
  ]
}
```

#### GET `/api/admin/dashboard/recent-activities`
Recent admin activities
```typescript
Query Params:
- limit?: number (default: 20)
- branchId?: string

Response:
{
  activities: AdminActivityLog[]
}
```

---

### 9. Category Management (`/api/admin/categories`)

#### GET `/api/admin/categories`
List categories
```typescript
Response:
{
  data: Category[]
}
```

#### POST `/api/admin/categories`
Create category (Super Admin)
```typescript
Request Body (multipart/form-data):
{
  name: string
  nameUz: string
  nameRu: string
  icon?: File
  sortOrder?: number
}

Response: Category
```

#### PATCH `/api/admin/categories/:id`
Update category
```typescript
Request Body:
{
  name?: string
  nameUz?: string
  nameRu?: string
  icon?: File
  sortOrder?: number
  isActive?: boolean
}

Response: Category
```

#### DELETE `/api/admin/categories/:id`
Delete category (soft delete)
```typescript
Response:
{
  success: boolean
}
```

---

### 10. User Management (`/api/admin/users`)

#### GET `/api/admin/users`
List users
```typescript
Query Params:
- page?: number
- limit?: number
- isVerified?: boolean
- search?: string // Phone, name, pinfl

Response:
{
  data: User[]
  pagination: {...}
}
```

#### GET `/api/admin/users/:id`
Get user details
```typescript
Response:
{
  user: User
  orders: Order[] // Recent orders
  payments: Payment[] // Recent payments
  creditInfo: {
    limit: number | null
    used: number
    available: number
    expiryDate: string | null
  }
}
```

#### PATCH `/api/admin/users/:id/credit-limit`
Manually adjust credit limit (Super Admin)
```typescript
Request Body:
{
  creditLimit: number
  expiryDays?: number // Extend expiry
  notes: string
}

Response: User
```

#### POST `/api/admin/users/:id/block`
Block user
```typescript
Request Body:
{
  reason: string
}

Response:
{
  success: boolean
}
```

---

### 11. Reports (`/api/admin/reports`)

#### GET `/api/admin/reports/sales`
Sales report
```typescript
Query Params:
- startDate: string
- endDate: string
- branchId?: string
- format?: 'json' | 'excel'

Response:
{
  summary: {
    totalOrders: number
    totalRevenue: number
    averageOrderValue: number
  }
  orders: Order[]
}
// Or Excel file download
```

#### GET `/api/admin/reports/installments`
Installment report
```typescript
Query Params:
- startDate: string
- endDate: string
- branchId?: string
- status?: 'active' | 'completed' | 'overdue'

Response:
{
  summary: {
    totalInstallments: number
    activeInstallments: number
    overduePayments: number
    totalReceivable: number
  }
  installments: Order[]
}
```

#### GET `/api/admin/reports/products`
Product performance report
```typescript
Query Params:
- startDate: string
- endDate: string
- branchId?: string
- categoryId?: string

Response:
{
  products: [
    {
      product: Product
      totalSold: number
      revenue: number
      averageRating: number
    }
  ]
}
```

---

### 12. Mobile App API (`/api`) - User endpoints

#### POST `/api/auth/send-otp`
Send OTP code to phone number
```typescript
Request Body:
{
  phoneNumber: string // +998901234567
}

Response:
{
  success: boolean
  message: string
}
```

#### POST `/api/auth/verify-otp`
Verify OTP and login/register
```typescript
Request Body:
{
  phoneNumber: string
  code: string // 6-digit code
}

Response:
{
  accessToken: string
  refreshToken: string
  user: {
    id: string
    phoneNumber: string
    name: string | null
    isVerified: boolean
    creditLimit: number | null
    usedLimit: number
    limitExpiryDate: string | null
  }
}
```

#### POST `/api/auth/refresh`
Refresh access token
```typescript
Request Body:
{
  refreshToken: string
}

Response:
{
  accessToken: string
  refreshToken: string
}
```

#### POST `/api/auth/logout`
Logout user (requires auth)
```typescript
Headers:
Authorization: Bearer {accessToken}

Response:
{
  success: boolean
}
```

---

### 2. User Profile (`/api/users`)

#### GET `/api/users/me`
Get current user profile
```typescript
Headers:
Authorization: Bearer {accessToken}

Response:
{
  id: string
  phoneNumber: string
  name: string | null
  dateOfBirth: string | null
  passportSeries: string | null
  passportNumber: string | null
  isVerified: boolean
  faceImageUrl: string | null
  creditLimit: number | null
  usedLimit: number
  availableLimit: number
  limitExpiryDate: string | null
}
```

#### PUT `/api/users/me`
Update user profile
```typescript
Headers:
Authorization: Bearer {accessToken}

Request Body:
{
  name?: string
  dateOfBirth?: string // ISO date
}

Response: User object
```

#### POST `/api/users/verify-identity`
Submit identity verification (Face + Passport)
```typescript
Headers:
Authorization: Bearer {accessToken}
Content-Type: multipart/form-data

Request Body (FormData):
{
  faceImage: File
  passportImage: File
  passportSeries: string
  passportNumber: string
  pinfl: string
  dateOfBirth: string
}

Response:
{
  success: boolean
  message: string
  isVerified: boolean
}
```

#### POST `/api/users/request-credit-limit`
Request credit limit (requires verification)
```typescript
Headers:
Authorization: Bearer {accessToken}

Request Body:
{
  requestedAmount: number // Should be 20000000 (20M)
}

Response:
{
  creditLimit: number
  limitExpiryDate: string
  message: string
}
```

---

### 3. Branches (`/api/branches`)

#### GET `/api/branches`
Get all active branches
```typescript
Query Params:
- page?: number (default: 1)
- limit?: number (default: 10)

Response:
{
  data: [
    {
      id: string
      name: string
      address: string
      phone: string
      latitude: number | null
      longitude: number | null
    }
  ],
  meta: {
    total: number
    page: number
    limit: number
    totalPages: number
  }
}
```

#### GET `/api/branches/:id`
Get branch by ID
```typescript
Response: Branch object with products count
```

---

### 4. Categories (`/api/categories`)

#### GET `/api/categories`
Get all active categories
```typescript
Query Params:
- lang?: 'uz' | 'ru' (default: 'uz')

Response:
{
  data: [
    {
      id: string
      name: string
      icon: string | null
      productsCount: number
    }
  ]
}
```

---

### 5. Products (`/api/products`)

#### GET `/api/products`
Get products with filters
```typescript
Query Params:
- page?: number (default: 1)
- limit?: number (default: 20)
- categoryId?: string
- branchId?: string
- search?: string
- minPrice?: number
- maxPrice?: number
- sortBy?: 'price' | 'rating' | 'newest'
- sortOrder?: 'asc' | 'desc'
- lang?: 'uz' | 'ru'

Response:
{
  data: [
    {
      id: string
      name: string
      description: string
      price: number
      discount: number
      finalPrice: number
      material: string
      weight: number
      images: string[]
      inStock: boolean
      rating: number
      reviewCount: number
      category: {
        id: string
        name: string
      }
      branch: {
        id: string
        name: string
      }
    }
  ],
  meta: {
    total: number
    page: number
    limit: number
    totalPages: number
  }
}
```

#### GET `/api/products/:id`
Get product by ID
```typescript
Response: Full product object
```

---

### 6. Favorites (`/api/favorites`)

#### GET `/api/favorites`
Get user favorites (requires auth)
```typescript
Headers:
Authorization: Bearer {accessToken}

Query Params:
- page?: number
- limit?: number

Response:
{
  data: [
    {
      id: string
      productId: string
      product: Product object
      createdAt: string
    }
  ],
  meta: { ... }
}
```

#### POST `/api/favorites`
Add to favorites
```typescript
Headers:
Authorization: Bearer {accessToken}

Request Body:
{
  productId: string
}

Response:
{
  id: string
  productId: string
  createdAt: string
}
```

#### DELETE `/api/favorites/:productId`
Remove from favorites
```typescript
Headers:
Authorization: Bearer {accessToken}

Response:
{
  success: boolean
}
```

#### GET `/api/favorites/check/:productId`
Check if product is favorited
```typescript
Headers:
Authorization: Bearer {accessToken}

Response:
{
  isFavorite: boolean
}
```

---

### 7. Cart (`/api/cart`)

#### GET `/api/cart`
Get user cart
```typescript
Headers:
Authorization: Bearer {accessToken}

Response:
{
  items: [
    {
      id: string
      productId: string
      quantity: number
      product: Product object
    }
  ],
  totalItems: number
  totalPrice: number
}
```

#### POST `/api/cart`
Add item to cart
```typescript
Headers:
Authorization: Bearer {accessToken}

Request Body:
{
  productId: string
  quantity: number
}

Response: CartItem object
```

#### PUT `/api/cart/:itemId`
Update cart item quantity
```typescript
Headers:
Authorization: Bearer {accessToken}

Request Body:
{
  quantity: number
}

Response: CartItem object
```

#### DELETE `/api/cart/:itemId`
Remove item from cart
```typescript
Headers:
Authorization: Bearer {accessToken}

Response:
{
  success: boolean
}
```

#### DELETE `/api/cart`
Clear cart
```typescript
Headers:
Authorization: Bearer {accessToken}

Response:
{
  success: boolean
}
```

---

### 8. Orders (`/api/orders`)

#### POST `/api/orders`
Create order (installment purchase)
```typescript
Headers:
Authorization: Bearer {accessToken}

Request Body:
{
  branchId: string
  items: [
    {
      productId: string
      quantity: number
    }
  ]
  installmentDetails: {
    totalMonths: number // 3-48
    monthlyPayment: number
    interestRate: number
  }
  deliveryAddress?: string
  deliveryPhone?: string
  notes?: string
}

Response:
{
  id: string
  orderNumber: string
  totalAmount: number
  monthlyPayment: number
  totalMonths: number
  nextPaymentDate: string
  status: string
  items: OrderItem[]
}
```

#### GET `/api/orders`
Get user orders (purchases)
```typescript
Headers:
Authorization: Bearer {accessToken}

Query Params:
- page?: number
- limit?: number
- status?: OrderStatus

Response:
{
  data: [
    {
      id: string
      orderNumber: string
      totalAmount: number
      isInstallment: boolean
      monthlyPayment: number
      totalMonths: number
      paidMonths: number
      remainingAmount: number
      nextPaymentDate: string
      status: string
      items: [{
        product: Product object
        quantity: number
        price: number
      }]
      createdAt: string
    }
  ],
  meta: { ... }
}
```

#### GET `/api/orders/:id`
Get order details
```typescript
Headers:
Authorization: Bearer {accessToken}

Response: Full order object with items and payments
```

#### GET `/api/orders/:id/payment-schedule`
Get payment schedule for order
```typescript
Headers:
Authorization: Bearer {accessToken}

Response:
{
  totalMonths: number
  paidMonths: number
  monthlyPayment: number
  schedule: [
    {
      monthNumber: number
      dueDate: string // 15th of each month
      amount: number
      isPaid: boolean
      paidAt: string | null
    }
  ]
}
```

---

### 9. Payments (`/api/payments`)

#### POST `/api/payments`
Make payment for order
```typescript
Headers:
Authorization: Bearer {accessToken}

Request Body:
{
  orderId: string
  amount: number
  paymentMethod: 'CASH' | 'CARD' | 'CLICK' | 'PAYME'
  transactionId?: string
}

Response:
{
  id: string
  amount: number
  status: string
  paymentDate: string
}
```

#### GET `/api/payments/order/:orderId`
Get payments for order
```typescript
Headers:
Authorization: Bearer {accessToken}

Response:
{
  data: Payment[]
}
```

---

## NestJS Project Structure

```
src/
├── main.ts
├── app.module.ts
├── common/
│   ├── decorators/
│   │   ├── current-user.decorator.ts
│   │   ├── current-admin.decorator.ts
│   │   └── roles.decorator.ts
│   ├── guards/
│   │   ├── jwt-auth.guard.ts
│   │   ├── admin-jwt-auth.guard.ts
│   │   └── roles.guard.ts
│   ├── filters/
│   │   └── http-exception.filter.ts
│   └── interceptors/
│       ├── transform.interceptor.ts
│       └── logging.interceptor.ts
├── config/
│   ├── database.config.ts
│   └── jwt.config.ts
├── prisma/
│   ├── prisma.module.ts
│   └── prisma.service.ts
│
├── ========== ADMIN MODULES ==========
│
├── admin/
│   ├── admin.module.ts
│   │
│   ├── auth/
│   │   ├── admin-auth.module.ts
│   │   ├── admin-auth.controller.ts
│   │   ├── admin-auth.service.ts
│   │   ├── strategies/
│   │   │   ├── admin-jwt.strategy.ts
│   │   │   └── admin-jwt-refresh.strategy.ts
│   │   └── dto/
│   │       ├── admin-login.dto.ts
│   │       └── create-admin.dto.ts
│   │
│   ├── admins/
│   │   ├── admins.module.ts
│   │   ├── admins.controller.ts
│   │   ├── admins.service.ts
│   │   └── dto/
│   │       ├── create-admin.dto.ts
│   │       └── update-admin.dto.ts
│   │
│   ├── dashboard/
│   │   ├── dashboard.module.ts
│   │   ├── dashboard.controller.ts
│   │   └── dashboard.service.ts
│   │
│   ├── verification-requests/
│   │   ├── verification-requests.module.ts
│   │   ├── verification-requests.controller.ts
│   │   ├── verification-requests.service.ts
│   │   └── dto/
│   │       ├── approve-request.dto.ts
│   │       └── reject-request.dto.ts
│   │
│   ├── products/
│   │   ├── admin-products.module.ts
│   │   ├── admin-products.controller.ts
│   │   ├── admin-products.service.ts
│   │   └── dto/
│   │       ├── create-product.dto.ts
│   │       └── update-product.dto.ts
│   │
│   ├── orders/
│   │   ├── admin-orders.module.ts
│   │   ├── admin-orders.controller.ts
│   │   ├── admin-orders.service.ts
│   │   └── dto/
│   │       └── update-order-status.dto.ts
│   │
│   ├── users/
│   │   ├── admin-users.module.ts
│   │   ├── admin-users.controller.ts
│   │   ├── admin-users.service.ts
│   │   └── dto/
│   │       └── update-credit-limit.dto.ts
│   │
│   ├── branches/
│   │   ├── admin-branches.module.ts
│   │   ├── admin-branches.controller.ts
│   │   ├── admin-branches.service.ts
│   │   └── dto/
│   │       ├── create-branch.dto.ts
│   │       └── update-branch.dto.ts
│   │
│   ├── categories/
│   │   ├── admin-categories.module.ts
│   │   ├── admin-categories.controller.ts
│   │   └── admin-categories.service.ts
│   │
│   ├── payments/
│   │   ├── admin-payments.module.ts
│   │   ├── admin-payments.controller.ts
│   │   └── admin-payments.service.ts
│   │
│   └── reports/
│       ├── reports.module.ts
│       ├── reports.controller.ts
│       └── reports.service.ts
│
├── ========== MOBILE APP MODULES ==========
│
├── auth/
│   ├── auth.module.ts
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── strategies/
│   │   ├── jwt.strategy.ts
│   │   └── jwt-refresh.strategy.ts
│   └── dto/
│       ├── send-otp.dto.ts
│       └── verify-otp.dto.ts
├── users/
│   ├── users.module.ts
│   ├── users.controller.ts
│   ├── users.service.ts
│   └── dto/
│       ├── update-user.dto.ts
│       ├── verify-identity.dto.ts
│       └── request-credit-limit.dto.ts
├── branches/
│   ├── branches.module.ts
│   ├── branches.controller.ts
│   └── branches.service.ts
├── categories/
│   ├── categories.module.ts
│   ├── categories.controller.ts
│   └── categories.service.ts
├── products/
│   ├── products.module.ts
│   ├── products.controller.ts
│   ├── products.service.ts
│   └── dto/
│       └── query-products.dto.ts
├── favorites/
│   ├── favorites.module.ts
│   ├── favorites.controller.ts
│   ├── favorites.service.ts
│   └── dto/
│       └── create-favorite.dto.ts
├── cart/
│   ├── cart.module.ts
│   ├── cart.controller.ts
│   ├── cart.service.ts
│   └── dto/
│       ├── add-to-cart.dto.ts
│       └── update-cart.dto.ts
├── orders/
│   ├── orders.module.ts
│   ├── orders.controller.ts
│   ├── orders.service.ts
│   └── dto/
│       └── create-order.dto.ts
└── payments/
    ├── payments.module.ts
    ├── payments.controller.ts
    ├── payments.service.ts
    └── dto/
        └── create-payment.dto.ts
```

---

---

## Environment Variables (.env)

```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/gold_mobile?schema=public"

# JWT - User
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_SECRET="your-refresh-secret-key"
JWT_REFRESH_EXPIRES_IN="7d"

# JWT - Admin (separate tokens)
ADMIN_JWT_SECRET="your-admin-super-secret-jwt-key"
ADMIN_JWT_EXPIRES_IN="8h"
ADMIN_JWT_REFRESH_SECRET="your-admin-refresh-secret-key"
ADMIN_JWT_REFRESH_EXPIRES_IN="30d"

# App
PORT=3000
NODE_ENV="development"

# SMS Provider (example: Playmobile)
SMS_API_URL="https://sms-api.uz/send"
SMS_API_KEY="your-sms-api-key"

# File Upload (MinIO/S3)
MINIO_ENDPOINT="localhost"
MINIO_PORT=9000
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadmin"
MINIO_BUCKET="gold-mobile"

# Credit Limit Settings
DEFAULT_CREDIT_LIMIT=20000000
CREDIT_LIMIT_DURATION_DAYS=1

# Admin Settings
SUPER_ADMIN_EMAIL="admin@goldmobile.uz"
SUPER_ADMIN_PASSWORD="change-me-in-production"
```

---

## Key Implementation Notes

### 1. Interest Rate Calculation
```typescript
// orders.service.ts
getInterestRate(months: number): number {
  if (months <= 3) return 0;
  if (months <= 6) return 0.05;
  if (months <= 12) return 0.10;
  if (months <= 24) return 0.15;
  return 0.20;
}

calculateInstallment(price: number, months: number) {
  const interestRate = this.getInterestRate(months);
  const totalAmount = price * (1 + interestRate);
  const monthlyPayment = totalAmount / months;
  
  return {
    totalAmount,
    monthlyPayment,
    interestRate,
  };
}
```

### 2. Payment Schedule Generation
```typescript
generatePaymentSchedule(order: Order) {
  const schedule = [];
  const startDate = new Date(order.createdAt);
  
  for (let i = 1; i <= order.totalMonths; i++) {
    const dueDate = new Date(startDate);
    dueDate.setMonth(dueDate.getMonth() + i);
    dueDate.setDate(15); // Always 15th
    
    schedule.push({
      monthNumber: i,
      dueDate,
      amount: order.monthlyPayment,
      isPaid: i <= order.paidMonths,
    });
  }
  
  return schedule;
}
```

### 3. Credit Limit Management
```typescript
async checkAvailableLimit(userId: string, amount: number) {
  const user = await this.prisma.user.findUnique({
    where: { id: userId },
  });
  
  const availableLimit = (user.creditLimit || 0) - user.usedLimit;
  
  // Check expiry
  if (user.limitExpiryDate && new Date() > user.limitExpiryDate) {
    throw new BadRequestException('Credit limit expired');
  }
  
  if (availableLimit < amount) {
    throw new BadRequestException('Insufficient credit limit');
  }
  
  return true;
}
```

### 4. Admin Role-Based Access Control
```typescript
// roles.decorator.ts
import { SetMetadata } from '@nestjs/common';
import { AdminRole } from '@prisma/client';

export const ROLES_KEY = 'roles';
export const Roles = (...roles: AdminRole[]) => SetMetadata(ROLES_KEY, roles);

// roles.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AdminRole } from '@prisma/client';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<AdminRole[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    
    if (!requiredRoles) {
      return true;
    }
    
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.role === role);
  }
}

// Usage in controller:
@Controller('admin/products')
@UseGuards(AdminJwtAuthGuard, RolesGuard)
export class AdminProductsController {
  
  @Post()
  @Roles(AdminRole.SUPER_ADMIN, AdminRole.BRANCH_ADMIN)
  async createProduct(@Body() dto: CreateProductDto, @CurrentAdmin() admin) {
    // Branch admin can only create for their branch
    if (admin.role === AdminRole.BRANCH_ADMIN) {
      dto.branchId = admin.branchId;
    }
    return this.productsService.create(dto);
  }
}
```

### 5. Activity Logging Interceptor
```typescript
// logging.interceptor.ts
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdminActivityLoggingInterceptor implements NestInterceptor {
  constructor(private prisma: PrismaService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const admin = request.user; // From JWT
    
    const action = `${request.method}_${request.route.path}`;
    
    return next.handle().pipe(
      tap(async (data) => {
        if (admin && request.method !== 'GET') {
          await this.prisma.adminActivityLog.create({
            data: {
              adminId: admin.id,
              action,
              entity: this.extractEntity(request.route.path),
              entityId: data?.id || null,
              details: {
                body: request.body,
                params: request.params,
              },
              ipAddress: request.ip,
            },
          });
        }
      }),
    );
  }
  
  private extractEntity(path: string): string {
    const parts = path.split('/');
    return parts[parts.length - 1] || 'unknown';
  }
}
```

### 6. Branch Admin Data Filtering
```typescript
// admin-products.service.ts
async findAll(query: QueryProductsDto, admin: Admin) {
  const where: any = {
    isActive: true,
  };
  
  // Branch admin sees only their branch products
  if (admin.role === AdminRole.BRANCH_ADMIN) {
    where.branchId = admin.branchId;
  } else if (query.branchId) {
    where.branchId = query.branchId;
  }
  
  if (query.categoryId) {
    where.categoryId = query.categoryId;
  }
  
  return this.prisma.product.findMany({
    where,
    include: {
      category: true,
      branch: true,
    },
    skip: (query.page - 1) * query.limit,
    take: query.limit,
  });
}
```

### 7. Verification Request Approval Flow
```typescript
// verification-requests.service.ts
async approveRequest(requestId: string, dto: ApproveRequestDto, adminId: string) {
  const request = await this.prisma.userVerificationRequest.findUnique({
    where: { id: requestId },
    include: { user: true },
  });
  
  if (!request) {
    throw new NotFoundException('Request not found');
  }
  
  if (request.status !== 'PENDING') {
    throw new BadRequestException('Request already processed');
  }
  
  // Update request
  await this.prisma.userVerificationRequest.update({
    where: { id: requestId },
    data: {
      status: 'APPROVED',
      reviewedBy: adminId,
      reviewedAt: new Date(),
      reviewNotes: dto.reviewNotes,
      approvedLimit: dto.approvedLimit,
    },
  });
  
  // Update user with credit limit
  const expiryDate = new Date();
  expiryDate.setDate(expiryDate.getDate() + 1); // 1 day
  
  await this.prisma.user.update({
    where: { id: request.userId },
    data: {
      isVerified: true,
      creditLimit: dto.approvedLimit,
      limitExpiryDate: expiryDate,
      name: request.name,
      dateOfBirth: request.dateOfBirth,
      passportSeries: request.passportSeries,
      passportNumber: request.passportNumber,
      pinfl: request.pinfl,
      faceImageUrl: request.faceImageUrl,
      passportImageUrl: request.passportImageUrl,
      verifiedAt: new Date(),
    },
  });
  
  // Send notification to user (SMS/Push)
  // await this.notificationService.sendVerificationApproved(request.user.phoneNumber);
  
  return { success: true };
}
```

### 8. Dashboard Statistics Calculation
```typescript
// dashboard.service.ts
async getStats(branchId?: string, startDate?: Date, endDate?: Date) {
  const where: any = {};
  
  if (branchId) {
    where.branchId = branchId;
  }
  
  if (startDate && endDate) {
    where.createdAt = {
      gte: startDate,
      lte: endDate,
    };
  }
  
  const [
    totalOrders,
    pendingOrders,
    completedOrders,
    cancelledOrders,
    totalUsers,
    verifiedUsers,
    totalProducts,
    activeInstallments,
    pendingRequests,
  ] = await Promise.all([
    this.prisma.order.count({ where }),
    this.prisma.order.count({ where: { ...where, status: 'PENDING' } }),
    this.prisma.order.count({ where: { ...where, status: 'DELIVERED' } }),
    this.prisma.order.count({ where: { ...where, status: 'CANCELLED' } }),
    this.prisma.user.count(),
    this.prisma.user.count({ where: { isVerified: true } }),
    this.prisma.product.count({ where: branchId ? { branchId } : {} }),
    this.prisma.order.count({
      where: {
        ...where,
        isInstallment: true,
        status: { notIn: ['CANCELLED', 'DELIVERED'] },
      },
    }),
    this.prisma.userVerificationRequest.count({
      where: {
        ...(branchId && { branchId }),
        status: 'PENDING',
      },
    }),
  ]);
  
  // Calculate revenue
  const orders = await this.prisma.order.findMany({
    where,
    select: { totalAmount: true },
  });
  
  const totalRevenue = orders.reduce((sum, order) => sum + order.totalAmount, 0);
  
  return {
    totalOrders,
    pendingOrders,
    completedOrders,
    cancelledOrders,
    totalRevenue,
    totalUsers,
    verifiedUsers,
    totalProducts,
    activeInstallments,
    pendingRequests,
  };
}
```

### 9. Super Admin Initial Setup
```typescript
// Create initial super admin on first run
// main.ts or app.module.ts bootstrap

async function createSuperAdmin(prisma: PrismaService) {
  const superAdminEmail = process.env.SUPER_ADMIN_EMAIL || 'admin@goldmobile.uz';
  
  const existing = await prisma.admin.findUnique({
    where: { email: superAdminEmail },
  });
  
  if (!existing) {
    const hashedPassword = await bcrypt.hash(
      process.env.SUPER_ADMIN_PASSWORD || 'admin123',
      10
    );
    
    await prisma.admin.create({
      data: {
        email: superAdminEmail,
        password: hashedPassword,
        name: 'Super Administrator',
        role: 'SUPER_ADMIN',
        isActive: true,
      },
    });
    
    console.log('✅ Super admin created:', superAdminEmail);
  }
}

// Call in bootstrap function
async function bootstrap() {
  const app = await NestJS.create(AppModule);
  const prisma = app.get(PrismaService);
  
  await createSuperAdmin(prisma);
  
  await app.listen(3000);
}
```

---

## Admin Panel Features Summary

### Super Admin Capabilities:
- ✅ Full system access
- ✅ Create/manage all admins (Super, Branch, Manager, Support)
- ✅ Create/manage all branches
- ✅ Create/manage categories
- ✅ View all products, orders, users across all branches
- ✅ Approve/reject verification requests from any branch
- ✅ Manually adjust user credit limits
- ✅ View system-wide analytics and reports
- ✅ Access all activity logs

### Branch Admin Capabilities:
- ✅ Manage products for their assigned branch only
- ✅ View orders for their branch
- ✅ Approve/reject verification requests for their branch
- ✅ View branch-specific analytics
- ✅ Manage payments for their branch orders
- ✅ Cannot create other admins
- ✅ Cannot modify branch settings

### Manager Capabilities:
- ✅ View-only access to products, orders, analytics
- ✅ Generate reports
- ✅ Cannot modify data

### Support Capabilities:
- ✅ View user information
- ✅ View orders
- ✅ Update order status
- ✅ Handle customer inquiries
- ✅ Cannot manage products or financial data

---

## Security Features

1. **Separate JWT tokens** for admin and users
2. **Role-based access control** with guards
3. **Activity logging** for all admin actions
4. **Branch isolation** for branch admins
5. **Password hashing** with bcrypt
6. **Refresh token rotation**
7. **IP address logging**
8. **Admin session tracking**

---

## Database Indexes for Performance

```prisma
// Already included in schema above
@@index([email])          // Admin email lookup
@@index([branchId])       // Branch admin filtering
@@index([phoneNumber])    // User phone lookup
@@index([pinfl])          // User PINFL lookup
@@index([userId, status]) // User requests filtering
@@index([branchId, status]) // Branch requests filtering
@@index([status])         // Request status filtering
@@index([adminId, createdAt]) // Activity logs pagination
@@index([isActive])       // Active branches/products
```

---

## Next Steps for Implementation

1. **Setup Project**:
   ```bash
   nest new gold-mobile-backend
   cd gold-mobile-backend
   npm install @prisma/client prisma bcrypt @nestjs/jwt @nestjs/passport passport-jwt class-validator class-transformer
   npx prisma init
   ```

2. **Configure Prisma**:
   - Copy schema from this doc to `prisma/schema.prisma`
   - Update `.env` with DATABASE_URL
   - Run: `npx prisma migrate dev --name init`
   - Run: `npx prisma generate`

3. **Create Modules**:
   - Start with `prisma` module
   - Then `admin/auth` module
   - Then `admin/dashboard` module
   - Add other admin modules
   - Add mobile app modules

4. **Implement Guards & Decorators**:
   - `AdminJwtAuthGuard`
   - `RolesGuard`
   - `@CurrentAdmin()` decorator
   - `@Roles()` decorator

5. **Add Interceptors**:
   - Activity logging
   - Transform response
   - Error handling

6. **Test Each Module**:
   - Unit tests for services
   - E2E tests for controllers
   - Test role-based access

7. **Deploy**:
   - Configure production environment
   - Setup PostgreSQL
   - Deploy to server
   - Setup reverse proxy (nginx)
   - Enable HTTPS

---

## Admin Panel Frontend (Bonus)

You can use any frontend framework (React, Vue, Angular). Key pages:

1. **Login Page**
2. **Dashboard** - Stats, charts, recent activities
3. **Verification Requests** - List, approve/reject with images
4. **Products** - CRUD with image upload
5. **Orders** - List, details, status update
6. **Users** - List, details, credit limit management
7. **Branches** - CRUD (super admin only)
8. **Categories** - CRUD (super admin only)
9. **Admins** - CRUD (super admin only)
10. **Reports** - Sales, installments, products
11. **Settings** - Profile, password change

---

**Complete! Bu dokumentatsiya bilan to'liq admin panel qo'shilgan backend tizimni yaratishingiz mumkin.**
  
  if (availableLimit < amount) {
    throw new BadRequestException('Insufficient credit limit');
  }
  
  // Check if limit expired
  if (user.limitExpiryDate && user.limitExpiryDate < new Date()) {
    throw new BadRequestException('Credit limit expired');
  }
  
  return availableLimit;
}

async updateUsedLimit(userId: string, amount: number) {
  await this.prisma.user.update({
    where: { id: userId },
    data: {
      usedLimit: {
        increment: amount,
      },
    },
  });
}
```

### 4. OTP Service
```typescript
async sendOtp(phoneNumber: string) {
  // Generate 6-digit code
  const code = Math.floor(100000 + Math.random() * 900000).toString();
  
  // Save to database
  await this.prisma.otpCode.create({
    data: {
      phoneNumber,
      code,
      expiresAt: new Date(Date.now() + 5 * 60 * 1000), // 5 min
    },
  });
  
  // Send SMS
  await this.smsService.send(phoneNumber, `Gold Imperia tasdiqlash kodi: ${code}`);
}

async verifyOtp(phoneNumber: string, code: string) {
  const otp = await this.prisma.otpCode.findFirst({
    where: {
      phoneNumber,
      code,
      isUsed: false,
      expiresAt: { gt: new Date() },
    },
  });
  
  if (!otp) {
    throw new BadRequestException('Invalid or expired OTP');
  }
  
  // Mark as used
  await this.prisma.otpCode.update({
    where: { id: otp.id },
    data: { isUsed: true },
  });
  
  return true;
}
```

---

## Testing Endpoints

Use Postman or Thunder Client with this collection structure:

1. **Auth Flow**: Send OTP → Verify → Get token
2. **User Profile**: Get/Update profile → Verify identity → Request credit
3. **Browse**: Get branches → Get categories → Get products
4. **Shopping**: Add to favorites → Add to cart → Create order
5. **Payments**: View orders → Payment schedule → Make payment

---

## Mobile App Integration Points

1. **Login**: OTP-based authentication
2. **Verification**: Face + Passport upload
3. **Credit**: Request and track 20M limit
4. **Shopping**: Browse, favorite, cart
5. **Installment**: 3-48 months with interest calculation
6. **Orders**: View purchases, payment schedule, history
7. **Payments**: Monthly payments on 15th
