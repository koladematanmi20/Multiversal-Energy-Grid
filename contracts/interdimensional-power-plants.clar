;; Interdimensional Power Plants Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var plant-counter uint u0)
(define-map power-plants uint {
    operator: principal,
    universe-id: (string-ascii 50),
    coordinates: (tuple (x int) (y int) (z int) (w int)),
    energy-type: (string-ascii 20),
    capacity: uint,
    current-output: uint,
    operational-status: (string-ascii 20)
})

;; Public Functions
(define-public (register-power-plant (universe-id (string-ascii 50)) (coordinates (tuple (x int) (y int) (z int) (w int))) (energy-type (string-ascii 20)) (capacity uint))
    (let
        (
            (plant-id (+ (var-get plant-counter) u1))
        )
        (asserts! (> capacity u0) err-invalid-parameters)
        (map-set power-plants plant-id {
            operator: tx-sender,
            universe-id: universe-id,
            coordinates: coordinates,
            energy-type: energy-type,
            capacity: capacity,
            current-output: u0,
            operational-status: "active"
        })
        (var-set plant-counter plant-id)
        (ok plant-id)
    )
)

(define-public (update-plant-output (plant-id uint) (new-output uint))
    (let
        (
            (plant (unwrap! (map-get? power-plants plant-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get operator plant)) err-not-authorized)
        (asserts! (<= new-output (get capacity plant)) err-invalid-parameters)
        (map-set power-plants plant-id
            (merge plant {
                current-output: new-output
            })
        )
        (ok new-output)
    )
)

(define-public (update-operational-status (plant-id uint) (new-status (string-ascii 20)))
    (let
        (
            (plant (unwrap! (map-get? power-plants plant-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get operator plant)) err-not-authorized)
        (asserts! (or (is-eq new-status "active") (is-eq new-status "inactive") (is-eq new-status "maintenance")) err-invalid-parameters)
        (map-set power-plants plant-id
            (merge plant {
                operational-status: new-status
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-power-plant (plant-id uint))
    (map-get? power-plants plant-id)
)

(define-read-only (get-plant-count)
    (var-get plant-counter)
)
