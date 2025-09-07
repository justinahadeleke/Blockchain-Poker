📖 README – Blockchain Poker Smart Contract

Overview

This smart contract implements a provably fair poker game on the Stacks blockchain. It leverages block hashes as seeds for shuffling, ensuring that neither player nor the contract deployer can manipulate the card distribution. The game flow follows standard Texas Hold’em rules: initial hand dealing, flop, turn, river, and declaring a winner.

✨ Features

Provably Fair Shuffling – Uses block hash as a deck seed for reproducibility and fairness.

Game Creation – Players can initiate new games with an opponent and a buy-in.

Hand Dealing – Automatic distribution of two cards to each player.

Community Cards – Flop, turn, and river phases follow sequential game states.

Game State Management – Ensures correct progression (waiting → dealt → flop → turn → river → completed).

Winner Declaration – Either player can end the game by declaring the winner.

Verification – On-chain verification of shuffle seed and deck order.

Card Readability – Converts card numbers into human-readable suits and ranks.

📂 Contract Structure

Data Variables

game-counter → Tracks the total number of games.

games → Stores all game-related data (players, deck, state, pot, cards, winner).

player-balances → Records player balances (currently placeholder, can be extended for STX transfers).

Core Public Functions

create-game – Starts a new poker game with a buy-in.

deal-initial-hands – Deals two cards to each player.

deal-flop – Deals the first three community cards.

deal-turn – Deals the fourth community card.

deal-river – Deals the fifth community card.

end-game – Declares the winner and finalizes the game.

Read-Only Functions

get-game – Retrieve full game state by game-id.

get-game-count – Returns total number of games created.

verify-shuffle – Verifies deck order using stored seed.

card-to-string – Converts a numeric card to its suit and rank.

Private Functions

generate-shuffled-deck – Creates a deterministic shuffled deck from the block hash seed.

apply-simple-shuffle – Applies a simple rotation-based shuffle (placeholder for Fisher-Yates).

🔄 Game Lifecycle Example

Player A creates a game against Player B with a buy-in.

Players deal initial hands (deal-initial-hands).

Community cards are revealed sequentially (deal-flop → deal-turn → deal-river).

Players can verify fairness with verify-shuffle.

A winner is declared using end-game.

🔒 Error Handling

ERR-NOT-AUTHORIZED – Unauthorized access attempt.

ERR-GAME-NOT-FOUND – Invalid game reference.

ERR-INVALID-MOVE – Action attempted out of sequence.

ERR-GAME-ALREADY-EXISTS – Duplicate game creation.

ERR-INSUFFICIENT-PLAYERS – Not enough players to start a game.