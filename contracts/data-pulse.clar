;; DataPulse Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-metric (err u101))
(define-constant err-invalid-interval (err u102))
(define-constant err-invalid-value (err u103))

;; Data structures
(define-map metrics
  { metric-id: uint }
  {
    name: (string-ascii 64),
    description: (string-ascii 256),
    last-updated: uint,
    current-value: uint,
    collection-interval: uint,
    min-value: uint,
    max-value: uint
  }
)

(define-map historical-data
  { metric-id: uint, timestamp: uint }
  { value: uint }
)

;; Data variables
(define-data-var next-metric-id uint u1)
(define-data-var update-count uint u0)

;; Administrative functions
(define-public (add-metric (name (string-ascii 64)) 
                         (description (string-ascii 256))
                         (interval uint)
                         (min-value uint)
                         (max-value uint))
  (let ((metric-id (var-get next-metric-id)))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (asserts! (>= max-value min-value) err-invalid-value)
      (map-insert metrics
        { metric-id: metric-id }
        {
          name: name,
          description: description,
          last-updated: block-height,
          current-value: u0,
          collection-interval: interval,
          min-value: min-value,
          max-value: max-value
        }
      )
      (var-set next-metric-id (+ metric-id u1))
      (ok metric-id)
    )
  )
)

;; Data recording functions  
(define-public (record-data-point (metric-id uint) (value uint))
  (let ((metric (unwrap! (map-get? metrics {metric-id: metric-id}) err-invalid-metric)))
    (begin
      (asserts! (and (>= value (get min-value metric)) 
                    (<= value (get max-value metric))) 
               err-invalid-value)
      (map-set metrics 
        {metric-id: metric-id}
        (merge metric {
          current-value: value,
          last-updated: block-height
        })
      )
      (map-insert historical-data
        {metric-id: metric-id, timestamp: block-height}
        {value: value}
      )
      (var-set update-count (+ (var-get update-count) u1))
      (ok true)
    )
  )
)

;; Read functions
(define-read-only (get-metric (metric-id uint))
  (map-get? metrics {metric-id: metric-id})
)

(define-read-only (get-historical-point (metric-id uint) (timestamp uint))
  (map-get? historical-data {metric-id: metric-id, timestamp: timestamp})
)

(define-read-only (get-update-count)
  (ok (var-get update-count))
)
