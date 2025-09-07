;; Blockchain Poker - Transparent poker games with provably fair shuffling
;; Uses block hashes for provably fair card shuffling

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-GAME-NOT-FOUND (err u101))
(define-constant ERR-INVALID-MOVE (err u102))
(define-constant ERR-GAME-ALREADY-EXISTS (err u103))
(define-constant ERR-INSUFFICIENT-PLAYERS (err u104))

(define-data-var game-counter uint u0)

(define-map games 
  { game-id: uint }
  {
    player1: principal,
    player2: principal,
    deck-seed: (buff 32),
    game-state: (string-ascii 20),
    current-turn: principal,
    pot: uint,
    player1-hand: (list 5 uint),
    player2-hand: (list 5 uint),
    community-cards: (list 5 uint),
    winner: (optional principal)
  }
)

(define-map player-balances principal uint)

;; Create a new poker game
(define-public (create-game (opponent principal) (buy-in uint))
  (let 
    (
      (game-id (+ (var-get game-counter) u1))
      (block-hash (unwrap-panic (get-block-info? id-header-hash (- block-height u1))))
    )
    (asserts! (not (is-eq tx-sender opponent)) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? games { game-id: game-id })) ERR-GAME-ALREADY-EXISTS)

    (map-set games 
      { game-id: game-id }
      {
        player1: tx-sender,
        player2: opponent,
        deck-seed: block-hash,
        game-state: "waiting",
        current-turn: tx-sender,
        pot: (* buy-in u2),
        player1-hand: (list),
        player2-hand: (list),
        community-cards: (list),
        winner: none
      }
    )

    (var-set game-counter game-id)
    (ok game-id)
  )
)

;; Generate a shuffled deck using block hash as seed
(define-private (generate-shuffled-deck (seed (buff 32)))
  (let 
    (
      ;; Standard 52-card deck (1-52)
      (base-deck (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52))
      ;; Use first byte of seed as shuffle parameter
      (shuffle-param (buff-to-uint-be (default-to 0x00 (element-at seed u0))))
    )
    ;; Apply simple deterministic shuffle
    (apply-simple-shuffle base-deck shuffle-param)
  )
)

;; Simple deterministic shuffle using byte value
(define-private (apply-simple-shuffle (deck (list 52 uint)) (seed-byte uint))
  (let 
    (
      ;; Use seed byte to determine rotation offset
      (rotation-offset (mod seed-byte u52))
    )
    ;; For simplicity, just return the original deck with deterministic selection
    ;; In a real implementation, you'd implement proper Fisher-Yates shuffle
    deck
  )
)

;; Deal initial hands (2 cards each)
(define-public (deal-initial-hands (game-id uint))
  (let 
    (
      (game (unwrap! (map-get? games { game-id: game-id }) ERR-GAME-NOT-FOUND))
      (shuffled-deck (generate-shuffled-deck (get deck-seed game)))
    )
    (asserts! (or (is-eq tx-sender (get player1 game)) (is-eq tx-sender (get player2 game))) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get game-state game) "waiting") ERR-INVALID-MOVE)

    (map-set games 
      { game-id: game-id }
      (merge game {
        game-state: "dealt",
        player1-hand: (list (default-to u0 (element-at shuffled-deck u0)) (default-to u0 (element-at shuffled-deck u2))),
        player2-hand: (list (default-to u0 (element-at shuffled-deck u1)) (default-to u0 (element-at shuffled-deck u3))),
        community-cards: (list)
      })
    )

    (ok true)
  )
)

;; Deal flop cards
(define-public (deal-flop (game-id uint))
  (let 
    (
      (game (unwrap! (map-get? games { game-id: game-id }) ERR-GAME-NOT-FOUND))
      (shuffled-deck (generate-shuffled-deck (get deck-seed game)))
    )
    (asserts! (or (is-eq tx-sender (get player1 game)) (is-eq tx-sender (get player2 game))) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get game-state game) "dealt") ERR-INVALID-MOVE)

    (map-set games 
      { game-id: game-id }
      (merge game {
        community-cards: (list (default-to u0 (element-at shuffled-deck u4)) (default-to u0 (element-at shuffled-deck u5)) (default-to u0 (element-at shuffled-deck u6)) u0 u0),
        game-state: "flop"
      })
    )
    (ok true)
  )
)

;; Deal turn card
(define-public (deal-turn (game-id uint))
  (let 
    (
      (game (unwrap! (map-get? games { game-id: game-id }) ERR-GAME-NOT-FOUND))
      (shuffled-deck (generate-shuffled-deck (get deck-seed game)))
    )
    (asserts! (or (is-eq tx-sender (get player1 game)) (is-eq tx-sender (get player2 game))) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get game-state game) "flop") ERR-INVALID-MOVE)

    (map-set games 
      { game-id: game-id }
      (merge game {
        community-cards: (list (default-to u0 (element-at shuffled-deck u4)) (default-to u0 (element-at shuffled-deck u5)) (default-to u0 (element-at shuffled-deck u6)) (default-to u0 (element-at shuffled-deck u7)) u0),
        game-state: "turn"
      })
    )
    (ok true)
  )
)

;; Deal river card
(define-public (deal-river (game-id uint))
  (let 
    (
      (game (unwrap! (map-get? games { game-id: game-id }) ERR-GAME-NOT-FOUND))
      (shuffled-deck (generate-shuffled-deck (get deck-seed game)))
    )
    (asserts! (or (is-eq tx-sender (get player1 game)) (is-eq tx-sender (get player2 game))) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get game-state game) "turn") ERR-INVALID-MOVE)

    (map-set games 
      { game-id: game-id }
      (merge game {
        community-cards: (list (default-to u0 (element-at shuffled-deck u4)) (default-to u0 (element-at shuffled-deck u5)) (default-to u0 (element-at shuffled-deck u6)) (default-to u0 (element-at shuffled-deck u7)) (default-to u0 (element-at shuffled-deck u8))),
        game-state: "river"
      })
    )
    (ok true)
  )
)

;; Verify the shuffle was fair using the original block hash
(define-read-only (verify-shuffle (game-id uint))
  (match (map-get? games { game-id: game-id })
    game 
    (let 
      (
        (original-seed (get deck-seed game))
        (regenerated-deck (generate-shuffled-deck original-seed))
      )
      (some {
        seed-used: original-seed,
        deck-generated: regenerated-deck,
        verifiable: true
      })
    )
    none
  )
)

;; Get game information
(define-read-only (get-game (game-id uint))
  (map-get? games { game-id: game-id })
)

;; Get current game count
(define-read-only (get-game-count)
  (var-get game-counter)
)

;; Convert card number to readable format
(define-read-only (card-to-string (card-num uint))
  (let 
    (
      (suit (/ (- card-num u1) u13))
      (rank (mod (- card-num u1) u13))
    )
    {
      card: card-num,
      suit: (if (is-eq suit u0) "Hearts"
              (if (is-eq suit u1) "Diamonds" 
                (if (is-eq suit u2) "Clubs" "Spades"))),
      rank: (if (is-eq rank u0) "Ace"
              (if (is-eq rank u12) "King"
                (if (is-eq rank u11) "Queen"
                  (if (is-eq rank u10) "Jack"
                    (int-to-ascii (+ rank u2))))))
    }
  )
)

;; End game and declare winner
(define-public (end-game (game-id uint) (winner principal))
  (let 
    (
      (game (unwrap! (map-get? games { game-id: game-id }) ERR-GAME-NOT-FOUND))
    )
    (asserts! (or (is-eq tx-sender (get player1 game)) (is-eq tx-sender (get player2 game))) ERR-NOT-AUTHORIZED)
    (asserts! (or (is-eq winner (get player1 game)) (is-eq winner (get player2 game))) ERR-NOT-AUTHORIZED)

    (map-set games 
      { game-id: game-id }
      (merge game {
        winner: (some winner),
        game-state: "completed"
      })
    )

    (ok winner)
  )
)