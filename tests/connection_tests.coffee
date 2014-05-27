batchId = "connectionBatch"

Batches.upsert batchId,
  $set: {}

batch = TurkServer.Batch.getBatch(batchId)

hitId = "connectionHitId"
assignmentId = "connectionAsstId"
workerId = "connectionWorkerId"

userId = "connectionUserId"

Meteor.users.upsert userId, $set: {workerId}

asst = null

instanceId = "connectionInstance"
instance = batch.createInstance()

# Create an assignment. Should only be used at most once per test case.
createAssignment = ->
  TurkServer.Assignment.createAssignment {
    batchId
    hitId
    assignmentId
    workerId
    acceptTime: Date.now()
    status: "assigned"
  }

withCleanup = TestUtils.getCleanupWrapper
  before: ->
  after: ->
    # Remove user from lobby
    batch.lobby.removeUser(asst)
    # Clear user group
    Partitioner.clearUserGroup(userId)
    # Clear any assignments
    Assignments.remove {}
    # Unset user state
    Meteor.users.update userId,
      $unset:
        "turkserver.state": null

Tinytest.add "connection - get existing assignment creates and preserves object", withCleanup (test) ->
  asstId = Assignments.insert {
    batchId
    hitId
    assignmentId
    workerId
    acceptTime: Date.now()
    status: "assigned"
  }

  asst = TurkServer.Assignment.getAssignment asstId
  asst2 = TurkServer.Assignment.getAssignment asstId

  test.equal asst2, asst

Tinytest.add "connection - assignment object preserved upon creation", withCleanup (test) ->
  asst = createAssignment()
  asst2 = TurkServer.Assignment.getAssignment asst.asstId

  test.equal asst2, asst

Tinytest.add "connection - user added to lobby", withCleanup (test) ->
  asst = createAssignment()
  asst._loggedIn()

  lobbyUsers = batch.lobby.getUsers()
  user = Meteor.users.findOne(userId)

  test.equal lobbyUsers.length, 1
  test.equal lobbyUsers[0]._id, userId

  test.equal user.turkserver.state, "lobby"

Tinytest.add "connection - user resuming into instance", withCleanup (test) ->
  asst = createAssignment()
  instance.addUser(userId)
  asst._loggedIn()

  user = Meteor.users.findOne(userId)

  test.equal batch.lobby.getUsers().length, 0
  test.equal user.turkserver.state, "experiment"

Tinytest.add "connection - user resuming into exit survey", withCleanup (test) ->
  asst = createAssignment()
  Meteor.users.update userId,
    $set:
      "turkserver.state": "exitsurvey"

  asst._loggedIn()

  user = Meteor.users.findOne(userId)

  test.equal batch.lobby.getUsers().length, 0
  test.equal user.turkserver.state, "exitsurvey"

Tinytest.add "connection - set payment amount", withCleanup (test) ->
  asst = createAssignment()
  test.isFalse asst.getPayment()

  amount = 1.00

  asst.setPayment(amount)
  test.equal asst.getPayment(), amount

  asst.addPayment(1.50)
  test.equal asst.getPayment(), 2.50

Tinytest.add "connection - increment null payment amount", withCleanup (test) ->
  asst = createAssignment()
  test.isFalse asst.getPayment()

  amount = 1.00
  asst.addPayment(amount)
  test.equal asst.getPayment(), amount