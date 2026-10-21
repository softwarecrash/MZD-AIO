import ipaddress,subprocess
address=input("CMU IPv4 [192.0.2.1]: ").strip() or "192.0.2.1"
address=str(ipaddress.IPv4Address(address))
subprocess.run(["ssh","-p","2223","-i",'PATH_TO_PRIVATE_KEY',"-o","IdentitiesOnly=yes","-o","HostKeyAlgorithms=+ssh-rsa","-o","PubkeyAcceptedAlgorithms=+ssh-rsa","cmu@"+address])
