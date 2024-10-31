# Virtual Property & Time Slot Reservation

This contract facilitates a virtual reservation system for properties where time slots can be reserved or purchased by users. Property owners (contract administrators) can define properties with base prices and a maximum number of time slots. Users can book available slots if they meet the contract's criteria.

## Contract Constants

- **contract-owner**: The primary contract owner with exclusive permissions for creating new properties.
- **Error Codes**:
  - **err-not-authorized**: Thrown if a non-authorized user attempts an action restricted to the owner.
  - **err-property-exists**: Returned when attempting to create a property that already exists.
  - **err-invalid-time-slot**: Indicates the slot does not exist or is unavailable.
  - **err-invalid-property-id**: Property ID is either invalid or duplicates an existing property.
  - **err-invalid-price**: Price provided is outside acceptable limits.
  - **err-invalid-slots**: Slot count is outside acceptable limits.
- **Property Constraints**:
  - **max-property-id**: Upper bound for property IDs.
  - **max-price**: Maximum allowable price for time slots.
  - **max-slots**: Maximum time slots per property.

## Data Structures

- **properties**: Stores each property’s details, including owner, base price, and total slots.
- **time-slots**: Holds individual time slots with details such as slot owner, start time, end time, and price.

## Functions

### Validation Functions
1. **is-valid-property-id**: Checks property ID validity.
2. **is-valid-price**: Verifies that the price is within the allowable range.
3. **is-valid-slots**: Ensures the number of slots is within bounds.
4. **is-valid-slot-id**: Confirms if the slot ID is valid for a property.

### Core Functions

#### Create Property
```clarity
(define-public (create-property (property-id uint) (base-price uint) (total-slots uint))
```
This function allows the contract owner to create a property with a unique property ID, setting a base price and total slot count.

#### Purchase Time Slot
```clarity
(define-public (purchase-time-slot (property-id uint) (slot-id uint))
```
Enables a user to purchase an available time slot for a specified property. This function checks the slot’s availability, transfers the specified amount, and updates the slot’s owner.

#### Check Time Slot Access
```clarity
(define-read-only (has-access (property-id uint) (user principal))
```
Checks if a user has access to a property during a specified time slot.

### Helper Functions

1. **is-authorized**: Confirms if the user is the contract owner.
2. **is-time-slot-available**: Verifies if a time slot is free for purchase.

## Practical Use Case

### Scenario: Virtual Real Estate for Events
Imagine a virtual event platform where users book property spaces for hosting digital exhibitions or meetings. This smart contract allows the platform owner to define properties (e.g., "Exhibition Hall 1") with specific time slots available for booking. Users can then pay to reserve these time slots for their events.

1. **Property Setup**:
   The platform admin creates a property:
   ```clarity
   (create-property u123 u1000 u10)
   ```
   This command sets up a property with ID `123`, a base price of `1000`, and `10` available slots.

2. **User Booking**:
   A user books a slot:
   ```clarity
   (purchase-time-slot u123 u5)
   ```
   This command books slot `5` for the property with ID `123`.

3. **Access Check**:
   Once booked, the user can verify their access using:
   ```clarity
   (has-access u123 tx-sender)
   ```

## Setup and Deployment

1. **Authorization**: Ensure the deploying user is set as the `contract-owner`.
2. **Deploy the Contract**: Compile and deploy the contract to your blockchain environment.
3. **Usage**:
   - The owner uses `create-property` to add new properties.
   - Users call `purchase-time-slot` to reserve available slots.

## Error Handling

Error codes are implemented to handle cases such as unauthorized actions, invalid IDs, incorrect pricing, and availability issues. Each error returns a unique code, allowing for easy troubleshooting and debugging.

## Future Enhancements

Potential improvements may include dynamic pricing based on demand, automated notifications for upcoming bookings, and additional access levels for sub-admins.