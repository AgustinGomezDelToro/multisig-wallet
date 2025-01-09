## MultiSigWallet

**Le MultiSigWallet est un smart contract Ethereum permettant la gestion d'un portefeuille multi-signatures. Il requiert au moins deux signatures parmi les signataires autorisés pour exécuter une transaction, garantissant ainsi une sécurité accrue pour la gestion de fonds partagés.**

Fonctionnalités Principales :
-   **Ajout de signataires** : Les signataires peuvent ajouter de nouveaux signataires au contrat.
-  **Retrait de signataires** : Les signataires peuvent supprimer des signataires existants sous réserve qu'au moins deux signataires restent actifs.
-  **Soumission de transactions** : Un signataire peut soumettre une nouvelle transaction.
-  **Confirmation de transactions** : Un signataire peut confirmer une transaction existante.
-  **Révocation de confirmation** : Un signataire peut révoquer une confirmation donnée précédemment.


Déploiement et Configuration :
```shell
constructor(address[] memory _signers, uint256 _requiredConfirmations)
```

- **_signers : Liste des adresses des signataires initiaux (minimum 3).**
- **_requiredConfirmations : Nombre minimal de confirmations pour exécuter une transaction (minimum 2).**

### Tests Principaux


- **testSubmitTransaction**: Vérifie la création d'une transaction.
- **testConfirmTransaction**: Vérifie la confirmation correcte d'une transaction.
- **testExecuteTransaction**: Vérifie l'exécution correcte après confirmations suffisantes.
- **testCannotExecuteWithInsufficientConfirmations**: Vérifie l'échec en cas de confirmations insuffisantes.
- **testAddSigner**: Teste l'ajout d'un nouveau signataire.
- **testRemoveSigner**: Teste la suppression d'un signataire avec minimum 2 signataires restants.
- **testRevokeConfirmation**: Teste la révocation d'une confirmation donnée précédemment.
- **testRevokeConfirmationFail**: Teste l'échec de révocation d'une confirmation non existante.



```shell
forge coverage
```