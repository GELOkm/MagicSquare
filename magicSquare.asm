# GELOkm

# Ce programme assembleur MIPS est conçu pour vérifier si un tableau carré
# donné est un carré magique qui est un arrangement de nombres dans un carré
# de taille n x n, où la somme des nombres dans chaque ligne, chaque colonne, 
# les deux diagonales principales et les quatres coins sont identiques.
# Ce programme trouve cette "somme magique" est vérifie ensuite que chaque
# "sous-somme" a la même valeur. Si le tableau satisfait toutes les conditions
# il est alors considéré comme un carré magique.


.data
tab: .space 64     # Réserve de l'espace pour 16 entiers (4 octets par entier)
taille: .word 16
elementsParLigne : .word 4
valeurMagique: .word 34
verifierTab: .space 64    # 16 emplacements, un pour chaque nombre de 1 à 16

borneMin: .word 1
BorneMax: .word 16

messageErreur1 : .asciiz "Le nombre entré ne se trouve pas entre 1 et 16.\n"
messageErreur2 : .asciiz "Le nombre entré à déjà été entré.\n"
messageNonMagique: .asciiz "Le tableau n'est pas un carré magique\n"
messageMagique: .asciiz "Carré magique !!! La valeur magique est:34\n"
espace : .asciiz " "
retourLigne: .asciiz "\n" 

.text
.globl main
main:
    la $t0, tab    # $t0 pointe vers le début du tableau
    li $t1, 0        # Initialise le compteur à 0

creerMat:
    li $v0, 5        # Prépare l'appel système pour lire un entier
    syscall          # Lit une valeur de l'utilisateur et la stocke dans $v0
    la $v1, borneMin
    lw $t4, 0($v1)  
    blt $v0, $t4, valeurInvalide
    la $v1, BorneMax
    lw $t4, 0($v1)
    bgt $v0, $t4, valeurInvalide
    j verifierValeur
    
verifierValeur:
	move $t4, $v0    # Copie la valeur lue dans $t0 pour utilisation future
	addi $t5, $t4, -1   
	la $t6, verifierTab     
	sll $t5, $t5, 2         # Multiplie l'indice par 4 
	add $t6, $t6, $t5       
	lw $t7, 0($t6)          # Charge la valeur à cette adresse dans $t3
	bnez $t7, valeurDejaEntree # Si $t3 != 0, la valeur est déjà entrée
	li $t7, 1         
	sw $t7, 0($t6)   
	j valeurValide 

    
valeurValide:
    sw $v0, 0($t0)   # Stocke la valeur lue à l'adresse actuelle 

    addi $t0, $t0, 4 
    addi $t1, $t1, 1 # Incrémentation

    li $t2, 16      
    bne $t1, $t2, creerMat # Si le compteur != 10, continue la boucle
    j initialiserMatrice

valeurInvalide:
    li $v0, 4            
    la $a0, messageErreur1     
    syscall             
    j creerMat

valeurDejaEntree:
    li $v0, 4            
    la $a0, messageErreur2     
    syscall              
    j creerMat
 
###################################################### IMPRIMER TABLEAU
    
initialiserMatrice: 
    la $t0, tab          # le début du tableau
    lw $t1, taille           # la taille du tableau
    lw $t3, elementsParLigne   # le nombre d'éléments par ligne
    li $t2, 0              # le compteur d'éléments traités

afficherMatrice:
    bge $t2, $t1, verifierLignes  # Sort s'ils sont tous affichés

    lw $a0, 0($t0)         
    li $v0, 1               
    syscall                
    li $v0, 4           
    la $a0, espace     
    syscall

    addi $t2, $t2, 1        # Incrémentation
    addi $t0, $t0, 4        # Élément suivant

    # Vérifier si on doit imprimer un saut de ligne
    rem $t4, $t2, $t3      
    beqz $t4, printRetourLigne 

    j afficherMatrice       # Revient au début de la boucle

printRetourLigne:
    la $a0, retourLigne      
    li $v0, 4              
    syscall                
    j afficherMatrice        # Retourne à la boucle principale


########################################## VERIFIER LIGNES

verifierLignes:
    lw $s0, elementsParLigne             
    la $s1, tab          # Début du tableau
    li $s2, 0              # Somme temporaire
    li $s3, 0              # Compteur de lignes
    li $s4, 0              # Compteur d'éléments 
    lw $s5, valeurMagique       # Somme magique
    j calculerSommeLigne

calculerSommeLigne:
    lw $t0, 0($s1)         
    add $s2, $s2, $t0      
    addi $s1, $s1, 4       
    addi $s4, $s4, 1       # Incrémentation

    # Vérifier si on a atteint la fin d'une ligne
    li $t1, 4              
    div $s4, $t1
    mfhi $t2               # $t2 = reste de $s4 / n
    beqz $t2, verifierSommeLigne # Si le reste est 0, vérifie la somme 

    j calculerSommeLigne

verifierSommeLigne:
    bne $s2, $s5, nonMagique # Si la somme != somme magique, carré non-magique
    li $s2, 0               # Réinitialise la somme temporaire
    addi $s3, $s3, 1        # Incrémentation
    li $t3, 3               # $t3 = n
    bne $s3, $t3, calculerSommeLigne # Continue s'il reste des lignes

########################################## VERIFIER COLONNES

   # Initialisations
initialiserColonnes:
    li $s3, 0                 

calculerSommeColonne:
    li $s2, 0                  
    li $s4, 0                 
    li $t5, 0                 

loopColonne:
    bge $s4, $s0, colonneSuivante  
    add $t6, $s1, $t5          # Calcule l'adresse de l'élément actuel 
    lw $t7, 0($t6)             
    add $s2, $s2, $t7          # Ajoute la valeur de l'élément à la somme
    addi $t5, $t5, 4           
    addi $s4, $s4, 1           
    j loopColonne     # Continue la boucle

colonneSuivante:
    # Compare la somme de la colonne à la somme magique
    bne $s2, $s5, nonMagique  # Si la somme != somme magique, carré non-magique
    addi $s3, $s3, 1          # Incrémente le compteur de colonnes
    li $s4, 0                 # Réinitialise le compteur d'éléments
move $t5, $s3                

    sll $t5, $t5, 2            # Multiplie l'indice de colonne par 4 
    blt $s3, $s0, calculerSommeColonne # Vérifie s'il reste des colonnes

    j initialiserDiagonales             

########################################## VERIFIER DIAGONALES

initialiserDiagonales:


# Initialisations
li $t0, 0                # Compteur pour la diagonale principale
li $t1, 0                # Somme de la diagonale principale
# Initialisation pour la diagonale secondaire
li $t2, 12           

li $t3, 0                # Somme de la diagonale secondaire
li $t4, 4                # Nombre d'éléments par ligne

calculerDiagonales:
    lw $t5, tab($t0)   
    add $t1, $t1, $t5    # Ajoute à la somme principale
    lw $t6, tab($t2)   
    add $t3, $t3, $t6    # Ajoute à la somme secondaire
    
    # Avance au prohcains éléments de chaque diagonale
    addi $t0, $t0, 20    
    addi $t2, $t2, 12    
    
    addi $t4, $t4, -1    # Décrémentation
    bnez $t4, calculerDiagonales # Continue s'il reste des éléments à traiter

# Compare les sommes des diagonales à la somme magique
lw $t7, valeurMagique        
bne $t1, $t7, nonMagique # Si la somme de la diagonale principale !=
bne $t3, $t7, nonMagique # Si la somme de la diagonale secondaire !=


########################################## VERIFIER COINS

# Calcul de la somme des coins après la vérification des diagonales
    li $s6, 0                 
    la $t0, tab              
    
    # Coin en haut à gauche
    lw $t1, 0($t0)             
    add $s6, $s6, $t1          # Ajoute à la somme des coins
    
    # Coin en haut à droite
    lw $t2, 12($t0)            
    add $s6, $s6, $t2          # Ajoute à la somme des coins
    
    # Coin en bas à gauche
    lw $t3, 48($t0)            # Charge le coin en bas à gauche 
    add $s6, $s6, $t3          # Ajoute à la somme des coins
    
    # Coin en bas à droite
    lw $t4, 60($t0)            # Charge le coin en bas à droite 
    add $s6, $s6, $t4          # Ajoute à la somme des coins


    # Comparaison de la somme des coins avec la somme magique
    lw $t5, valeurMagique
    bne $s6, $t5, nonMagique    

    # Si le programme arrive ici, le carré est magique

    # Affiche un message indiquant que le tableau est un carré magique.
    li $v0, 4
    la $a0, messageMagique
    syscall
    j finirProgramme

nonMagique:
    # Affiche un message indiquant que le tableau n'est pas un carré magique.
    li $v0, 4
    la $a0, messageNonMagique
    syscall
    j finirProgramme

finirProgramme:
    li $v0, 10                   # Syscall pour terminer le programme
    syscall