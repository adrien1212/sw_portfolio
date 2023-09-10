---
title: Concevoir un distributeur automatique (state design pattern)
author: Adrien CAUBEL
date: 21/04/2022
keywords: Design Pattern State, state, vendor machine, Java Design Pattern
---

La conception d’un distributeur automatique de boisson fait partie des questions courantes lors d’entretien d’embauche.

Dans cet article nous allons voir comment le patron de conception Etat (State) nous permet de résoudre ce problème.

**Prérequis**

* UML
* Design pattern state (est un +) [https://youtu.be/7N8fE4sV8js](https://youtu.be/7N8fE4sV8js)
* 10min pour lire l’article 😉

# Machine à état fini

Un distributeur automatique peut être vu comme une machine à état fini. Pour simplifier le problème nous allons représenter seulement les quatres états suivants :

* *Prêt*
* *Annuler*, lorsque la transaction est annulée
* *RendreMonnaie*, lorsque la monnaie est rendue au client
* *DistribuerBoisson*, lorsque la boisson est distribuée

![Machine a état finie d’un distributeur automatique](https://cdn-images-1.medium.com/max/2532/1*2ZXuMMZA2ozx922KK9lzdw.png)*Machine a état finie d’un distributeur automatique*

Puis nous passons d’un état à un autre grâce aux transitions représantant l’action à effectuer :

* Pour passer de *Pret* à *RendreMonnai* il faut que l’utilisateur ait validé son choix
* Pour passer de *DistribuerBoisson* à *Prêt* il faut que la machine ait distribué la boisson demandée.

En bleu, nous avons représenté les transitions automatiques; i.g. que le distributeur gère seul le passage à l’état suivant.

# **Diagramme de classe**

La machine à état fini permet de visualiser le problème, néanmoins un diagramme de classe est nécessaire afin de traduire notre problème en Orientée Objets

![](https://cdn-images-1.medium.com/max/5142/1*ChHsGLzp-4XNUmnI_U8wxA.png)

**IVendorMachine**

Représente l’API de notre service. Le client effectue des requêtes (=> prefix *request*)

**VendorMachineContext**

La *balance* permet de savoir si l’utilisateur a saisi assez d’argent pour acheter une boisson

Le *totalBalance* représente l’argent disponible dans le distributeur automatique

Connait l’état courant du distributeur automatique grâce à l’attribut *state
*Chaque état (IVendorState) modifiera l’état du distributeur automatique

**IVendorState**

Les implémentations vont effectuer une action (e.g. rendre la monnaie) puis positionner la machine à l’état suivant (e.g. DispenseItem)

Si dans un état une action n’est pas possible (e.g. être dans *Ready* et effectuer l’action *distribuer item*) alors l’exception IllegalVendorStateException sera levée

# Code

**Classe Item**
```Java
public class Item {
   private String name;

   private double price;

   private int quantity;
}
```
**Classe VendorMachineContext**
```Java
public class VendorMachineContext implements IVendorMachine {

   @NonNull
   private Map<Integer, Item> itemsByProductCode;
   
   @NonNull
   private double balance;
   
   @NonNull 
   private double totalMoney;
   
   private VendorState state = new Ready(this);


   public void addTotalMoney(double money) {
      totalMoney += money;
   }
   
   public void addBalance(double amount) {
      balance += amount;
   }


   public void requestInsertCash(double money) {
      this.state.insertCash(money);
   }
   
   public void requestDispenseMoney(int productCode) {
      this.state.dispenseMoney(productCode);
   }

   public void requestDispenseItem(int productCode) {
      this.state.dispenseItem(productCode);
   }
   
   public void requestCancelTransaction() {
      this.state.cancelTransaction();
   }
}
```
* L’état de départ est Ready

* Lorsqu’une *requête* est effectuée elle est déléguée à l’état courant du distributeur (i.g. *Ready*, *Cancel*, *RefoundChange* ou *DispenseItem*)

**Etat Ready**
```Java
public class Ready implements VendorState {

   private VendorMachineContext vendorMachine;
   
   @Override
   public void insertCash(double amount) {
      vendorMachine.addBalance(amount);
   }

   @Override
   public void dispenseMoney(int productCode) {
      if(vendorMachine.getBalance() >= vendorMachine.getItemsByProductCode().get(productCode).getPrice()) {
         // Passer à l'état RefoundChange
         vendorMachine.setState(new RefoundChange(this.vendorMachine));
         vendorMachine.requestDispenseMoney(productCode);
      } else {
         // Pas assez d'argent, on reste dans l'état Ready
         System.out.println("Vous n'avez pas inséré assez d'argent pour ce produit");
      }
   }

   @Override
   public void dispenseItem(int productCode) {
      throw new IllegalVendorStateException();
   }

   @Override
   public void cancelTransaction() {
      throw new IllegalVendorStateException();
   }
}
```
Dans l’état Ready on peut effectuer deux actions :

* Si on insère de l’argent Alors on reste dans l’état Ready
* Si on appuie le bouton validé et qu’on a donner assez d’argent (transition *item sélectionné*) alors on passe à l’état *RefoundChange* et on effectue la requête.
> On n’a pas de transition ItemSelected le fait d’appuyer sur valider n’est qu’une action visuelle. Derrière (back-end) ce qu’on fait concrètement s’est de rendre la monnaie puis dérouler les états.

**Etat RefoundChange**
```Java
public class RefoundChange implements VendorState {

   private VendorMachineContext vendorMachine;
   
   @Override
   public void insertCash(double amount) {
      throw new IllegalVendorStateException();
   }

   @Override
   public void dispenseMoney(int productCode) {
      // Rendre la monnaie
      System.out.println("Monnaie : " + (this.vendorMachine.getBalance() - this.vendorMachine.getItemsByProductCode().get(productCode).getPrice()));
      
      // Mettre à jour la balance et le totalAmount
      this.vendorMachine.setBalance(0);
      this.vendorMachine.addTotalMoney(this.vendorMachine.getItemsByProductCode().get(productCode).getPrice());
      
      // On va l'état DispenseItem
      this.vendorMachine.setState(new DispenseItem(this.vendorMachine));
      this.vendorMachine.requestDispenseItem(productCode);
   }

   @Override
   public void dispenseItem(int productCode) {
      throw new IllegalVendorStateException();
   }

   @Override
   public void cancelTransaction() {
      throw new IllegalVendorStateException();
   }
}
```
* Si on est dans l’état RefoundChange on ne peut que rendre la monnaie puis passer dans l’état DispenseItem

**Etat** **DispenseItem**
```Java
public class DispenseItem implements VendorState {

   private VendorMachineContext vendorMachine;
   
   @Override
   public void insertCash(double amount) {
      throw new IllegalVendorStateException();
   }

   @Override
   public void dispenseMoney(int productCode) {
      throw new IllegalVendorStateException();
   }

   @Override
   public void dispenseItem(int productCode) {
      System.out.println("Voici votre item : " + vendorMachine.getItemsByProductCode().get(productCode).getName());
   
      // Retour à Ready
      this.vendorMachine.setState(new Ready(vendorMachine));
   }

   @Override
   public void cancelTransaction() {
      throw new IllegalVendorStateException();
   }
}
```
* Une fois l’item distribué on retourne automatiquement dans l’état initial Ready.

**Etat Cancel**
```Java
public class Cancelled implements VendorState {

   private VendorMachine vendorMachine;
   
   @Override
   public void insertCash(double amount) {
      throw new IllegalVendorStateException();
   }

   @Override
   public void dispenseMoney(int productCode) {
      throw new IllegalVendorStateException();
   }

   @Override
   public voidpublic class Cancelled implements VendorState {

   private VendorMachine vendorMachine;
   
   @Override
   public void insertCash(double amount) {
      throw new IllegalVendorStateException();
   }
   ```

**Classe client**
```Java
public static void main(String[] args) {
   IVendorMachine machine = new VendorMachineContext(initVendorMachine(), 0.0, 10.0);
   machine.requestInsertCash(2.0);
   
   machine.requestDispenseMoney(1);
}


private static Map<Integer, Item> initVendorMachine() {
   Map<Integer, Item> itemsByProductCode = new HashMap<>();
   itemsByProductCode.put(1, new Item("Coca", 1.5, 10));
   itemsByProductCode.put(2, new Item("IceTea", 1.5, 10));
   itemsByProductCode.put(3, new Item("Eau", 0.5, 10));
   return itemsByProductCode;
}
```
```
OUTPUT : 
   Monnaie : 0.5
   Voici votre item : Coca
```
# Conclusion

La machine a état fini permet de comprendre le problème mais nous ne pouvons pas directement la traduire en design pattern State (e.g. pas de transition itemSelected)

Dans le design pattern State :

* Le context connait l’état en cours et délègue l’action demandée à l’état en cours
* L’état en cours effectue l’action puis change l’état courant du context

Mon site web : [https://adriencaubel.fr](https://adriencaubel.fr)  
Vidéo design pattern State : [https://youtu.be/7N8fE4sV8js](https://youtu.be/7N8fE4sV8js)
