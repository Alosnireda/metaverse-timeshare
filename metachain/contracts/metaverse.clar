;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-property-exists (err u101))
(define-constant err-invalid-time-slot (err u102))

;; Define data structures
(define-map properties
    { property-id: uint }
    { owner: principal, base-price: uint, total-slots: uint }
)

(define-map time-slots
    { property-id: uint, slot-id: uint }
    { owner: principal, start-time: uint, end-time: uint, price: uint }
)

;; Create new VR property
(define-public (create-property (property-id uint) (base-price uint) (total-slots uint))
    (let ((sender tx-sender))
        (if (is-authorized sender)
            (begin
                (map-insert properties
                    { property-id: property-id }
                    { owner: sender, 
                      base-price: base-price, 
                      total-slots: total-slots }
                )
                (ok true))
            err-not-authorized
        )
    )
)

;; Purchase time slot
(define-public (purchase-time-slot (property-id uint) (slot-id uint))
    (let ((slot (unwrap! (map-get? time-slots 
                            { property-id: property-id, slot-id: slot-id })
                        err-invalid-time-slot))
          (sender tx-sender))
        (if (is-time-slot-available property-id slot-id)
            (begin
                (try! (stx-transfer? (get price slot) sender (get owner slot)))
                (map-set time-slots
                    { property-id: property-id, slot-id: slot-id }
                    { owner: sender,
                      start-time: (get start-time slot),
                      end-time: (get end-time slot),
                      price: (get price slot) }
                )
                (ok true))
            err-invalid-time-slot
        )
    )
)

;; Check if user has access to property at current time
(define-read-only (has-access (property-id uint) (user principal))
    (let ((current-time block-height))
        (filter check-time-slot
            (map-get? time-slots { property-id: property-id })
        )
    )
)

;; Helper functions
(define-private (is-authorized (user principal))
    (is-eq user contract-owner)
)

(define-private (is-time-slot-available (property-id uint) (slot-id uint))
    (let ((slot (unwrap! (map-get? time-slots 
                            { property-id: property-id, slot-id: slot-id })
                        false)))
        (is-none (get owner slot))
    )
)