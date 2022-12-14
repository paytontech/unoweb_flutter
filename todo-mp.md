# todo-mp
I intend on adding online multiplayer to this game, this is how I intend to do it.

## Architecture
### The basics
I neither have the money nor patience to set up servers for this thing which I'll likely stop maintaining within the month, so it's going to be ~~Peer-To-Peer~~ multiplayer using ~~WebSockets~~ Firestore.

When creating a room, the game generates a 6-digit code that others can use to join the room. I really don't know how to do discovery, so this part will be done using something like Firebase. When a user creates a room, the game generates a code and puts that, along with a WebSocket URL, on Firestore, which others can access.

### Sync
Undoubtedly the most important & really the point of online multiplayer is syncing game states between players. I hope my method for doing so will be simple, for I have no other way of doing this.

Let's say the current player is a player with the ID of 0. When the player makes a move (plays/draws a card) the player's client will update their own gameData object, and then using something like Socket.IO, will broadcast that gameData object to all of the other clients. The other clients will accept this gameData object without question and render it. This is peak security.

### Accounts/Authentication
Honestly, i don't really care too much about this, but because bots are a thing, I'll probably just use Firebase Auth. Since I'm using Firebase already for game discovery, this shouldn't be all that hard to implement.

## TODO
This is purely here for me to track my progress.
- [ ] Prepare base game for multiplayer (basically just remove any reliance on the render system that the player is ID 0, and implement a way for client to know which player is theirs. this will likely tie in with auth system)
- [x] ~~Find a suitable websocket library (Socket.IO)~~ (no good websocket libraries for Dart/Flutter. will use Firestore)
- [ ] Get game data syncing between clients
- [ ] Add extra comfort features (usernames, profile pictures, rules, etc.)

## My Journey with Multiplayer
Alright, if you don't like reading my ramblings or just reading about code in general, stop reading here. As I start to work on this more, I'll write stuff about my experience here I think.

While I was beginning my work on multiplayer for this, I realized that there are not very many WebSocket libraries for Dart/Flutter. The very few WebSocket libraries that do exist have little-to-no or very bad documentation. I don't know why I didn't do this initially, but I'm just going to use Firestore for this. It is so much easier than WebSockets, and has great documentation.
