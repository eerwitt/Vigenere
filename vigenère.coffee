cipher = require('./run-cipher')

key = "CRYPTO"
message = "WHATANICEDAYTODAY"

vigenèreEncrypt = (key, message) ->
  cipher.run key, message, (keyCharacterCode, messageCharacterCode, alphabetSize) ->
    (keyCharacterCode + messageCharacterCode) % alphabetSize

vigenèreDecrypt = (key, encryptedMessage) ->
  cipher.run key, encryptedMessage, (keyCharacterCode, messageCharacterCode, alphabetSize) ->
    (messageCharacterCode - keyCharacterCode + alphabetSize) % alphabetSize

encryptedMessage = vigenèreEncrypt(key, message)
decryptedMessage = vigenèreDecrypt(key, encryptedMessage)

console.log """
  Encrypting #{message} with a key of #{key} using Vigenère cipher.
  Encrypted message is #{ encryptedMessage }.
  Decrypted message is #{ decryptedMessage }.
"""

runTests = ->
  assert = require 'assert'

  key = "CRYPTO"
  message = "WHATANICEDAYTODAY"

  assert.equal vigenèreEncrypt(key, message), "ZZZJUCLUDTUNWGCQS"
  assert.equal vigenèreEncrypt("ABC", "ABC"), "BDF"
  assert.equal vigenèreEncrypt("ABC", "A"), "B"
  assert.equal vigenèreEncrypt("Z", "ZAZ"), "ZAZ" #Interesting
  assert.equal vigenèreEncrypt("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"), "BDFHJLNPRTVXZBDFHJLNPRTVXZ"
  assert.equal vigenèreEncrypt("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "ZZZZZZZZZZZZZZZZZZZZZZZZZZ"), "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  assert.equal vigenèreDecrypt(key, "ZZZJUCLUDTUNWGCQS"), message
  assert.equal vigenèreDecrypt("ABC", "BDF"), "ABC"
  assert.equal vigenèreDecrypt("ABC", "B"), "A"
  assert.equal vigenèreDecrypt("Z", "ZAZ"), "ZAZ" #Interesting
  assert.equal vigenèreDecrypt("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "BDFHJLNPRTVXZBDFHJLNPRTVXZ"), "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  assert.equal vigenèreDecrypt("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"), "ZZZZZZZZZZZZZZZZZZZZZZZZZZ" # Hehe sweet

runTests()
