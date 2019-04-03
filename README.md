# Distriduted Systems 2019 (Tampere University)

In this repository you can find the examples of solving and implementing main problems of distributed systems (e.g. **coordination problem, vector timestamps, two-phase commiting protocol (2PC), three-phase commiting protocol (3PC)** and so on) using functional language Erlang.


## Structure

### Folder №1:
- **task12** - Coordination problem tested with two processes under the assumption that no failures take place
- **task13** - Implementation of Lamport timestamps
- **task14** - Implementation of vector timestamps

### Folder №2:
- **task21** - Implementation of invitation-based leader election
- **task22** - Distributed locking with three data storage processes, three data items and three processes that ask for exclusive and shared locks
- **task24** - Distributed locking under the assumption that processes can fail after asking for resources

### Folder №3:
- **task31** - Smart vector timestamps
- **task32** - Centralised (coordinator-based) 2PC protocol for two participants and a coordinator
- **task34** - Implementation of a version of 2PC with coordinator, where, once having voted Yes, a participant can send "Cancel" to the coordinator, hoping the coordinator will roll back the transaction

### Folder №4:
- **task41** - Implementation of the basic (voting) part of 3PC with the possibility for processes to fail 
- **task42** - Termination protocol added to task41
- **task43** - Implementation of a centralised multiversion concurrency control
- **task44** - The answer on "Suppose that the coordinator uses 3PC but one of the participants only knows 2PC and does not respond to "Prepare-commit" messages. What will happen?"

### Folder №5:
- **task51** - Two functions and a function that starts two processes, each running one of the functions.The first process gets a timeout value as a parameter. It sends a message to the second process and waits until it either receives a message back or times out. The second process, when getting a message,  waits a random time and then sends the message back.
- **task52** - Implementation of the 2PC protocol using timeouts 
- **task53** - 2PC participants consist of two parts: a supervisor process and the actual participant. The participant participates in the voting. When it receives a message, it will randomly either work normally or crash (simulates failing participants). If the process crashes, the supervisor restarts the participant, which enters recovery. The state should be communicated with the crash to the supervisor
- **task54** - Client-server system using the style of "Robust Erlang". The client sends two numbers and an operation to the server. The operation could be adding, subtracting, multiplying or dividing. The server sends the result back. If the server crashes, it is restarted by a supervisor

### Folder №6:
- **task61** - Three processes that exchange messages, encoded by XOR of the same pad.
- **task62** - Three processes that each have a private-public key pair (you need to read in the keys from files)
- **task63** - This task is for testing signatures. Two processes: one sends messages with signatures (that process needs a private key), the other uses the public key of the sending process to test the incoming messages and outputs wether the message was correctly signed.
- **task64** - _Byzantine generals_: Implementation of a function, that initially is given if it is faulty, correct, or random. 
    - A correct process forwards the first message as it is and decides according to majority. 
    - A faulty process forwards the opposite of the first received message. 
    - A random process makes a random choice and sends a random message. 
The processes are to decide on the lunch place (Pinni B or Main building). A process waits a random time (max 1 second) before sending each message. Once a process has received a message from everyone, it decides. Each process sends one message to all processes. One of the processses needs to initiate the voting. The others start voting upon receiving the first message.
