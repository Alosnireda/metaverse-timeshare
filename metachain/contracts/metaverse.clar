;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-property-exists (err u101))
(define-constant err-invalid-time-slot (err u102))
(define-constant err-invalid-property-id (err u103))
(define-constant err-invalid-price (err u104))
(define-constant err-invalid-slots (err u105))
(define-constant max-property-id u1000000)
(define-constant max-price u1000000000)
(define-constant max-slots u100)

;; Define data structures
(define-map properties
    { property-id: uint }
    { owner: principal, base-price: uint, total-slots: uint }
)

(define-map time-slots
    { property-id: uint, slot-id: uint }
    { owner: principal, start-time: uint, end-time: uint, price: uint }
)

;; Validation functions
(define-private (is-valid-property-id (property-id uint))
    (and 
        (> property-id u0)
        (<= property-id max-property-id)
        (is-none (map-get? properties { property-id: property-id }))
    )
)

(define-private (is-valid-price (price uint))
    (and 
        (> price u0)
        (<= price max-price)
    )
)

(define-private (is-valid-slots (slots uint))
    (and 
        (> slots u0)
        (<= slots max-slots)
    )
)

(define-private (is-valid-slot-id (property-id uint) (slot-id uint))
    (match (map-get? properties { property-id: property-id })
        property (< slot-id (get total-slots property))
        false
    )
)

;; Create new VR property
(define-public (create-property (property-id uint) (base-price uint) (total-slots uint))
    (let ((sender tx-sender))
        (asserts! (is-authorized sender) err-not-authorized)
        (asserts! (is-valid-property-id property-id) err-invalid-property-id)
        (asserts! (is-valid-price base-price) err-invalid-price)
        (asserts! (is-valid-slots total-slots) err-invalid-slots)
        (ok (map-insert properties
            { property-id: property-id }
            { owner: sender, 
              base-price: base-price, 
              total-slots: total-slots }
        ))
    )
)

;; Purchase time slot
(define-public (purchase-time-slot (property-id uint) (slot-id uint))
    (let ((sender tx-sender))
        (asserts! (is-valid-slot-id property-id slot-id) err-invalid-time-slot)
        (match (map-get? time-slots { property-id: property-id, slot-id: slot-id })
            slot 
                (if (is-time-slot-available property-id slot-id)
                    (begin
                        (try! (stx-transfer? (get price slot) sender (get owner slot)))
                        (ok (map-set time-slots
                            { property-id: property-id, slot-id: slot-id }
                            { owner: sender,
                              start-time: (get start-time slot),
                              end-time: (get end-time slot),
                              price: (get price slot) }
                        ))
                    )
                    err-invalid-time-slot
                )
            err-invalid-time-slot
        )
    )
)

;; Check if time slot is valid for current time
(define-private (check-time-slot (slot-entry {
    owner: principal,
    start-time: uint,
    end-time: uint,
    price: uint
}) (user principal))
    (and 
        (is-eq (get owner slot-entry) user)
        (>= block-height (get start-time slot-entry))
        (<= block-height (get end-time slot-entry)))
)

;; Check if user has access to property at current time
(define-read-only (has-access (property-id uint) (user principal))
    (let ((slot (map-get? time-slots { property-id: property-id, slot-id: u0 })))
        (match slot
            time-slot (check-time-slot time-slot user)
            false
        )
    )
)

;; Helper functions
(define-private (is-authorized (user principal))
    (is-eq user contract-owner)
)

(define-private (is-time-slot-available (property-id uint) (slot-id uint))
    (match (map-get? time-slots { property-id: property-id, slot-id: slot-id })
        slot false  ;; If slot exists, it's not available
        true    ;; If slot doesn't exist, it's available
    )
)