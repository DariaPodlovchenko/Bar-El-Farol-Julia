using Gtk
using Plots
using Random

# Paramètres 
N = 100                # Nombre d'agents (les personnes qui décident d'aller au bar)
T = 50                 # Nombre de semaines (la durée totale de la simulation)
threshold = 30         # Seuil de fréquentation confortable (le bar est confortable si moins de 30 personnes y vont)
preference_shift = 10  # Variation maximale des préférences chaque semaine

# Fonction pour générer les données de fréquentation
function generate_attendance()
    attendance = zeros(Float64, T)  # Initialiser un tableau pour stocker la fréquentation 
    
    # Initialiser les préférences des agents (valeurs entre 0 et 100)
    preferences = rand(N) * 100  

    # Simulation de la fréquentation chaque semaine

    # Ce bloc simule la fréquentation semaine par semaine. Pour chaque semaine, on calcule si chaque agent décide ou non d'aller au bar.
    # Les agents ajustent leurs préférences de manière aléatoire à chaque itération, puis décident d'aller au bar en fonction de la probabilité calculée.
    # Cette probabilité dépend de la différence entre leurs préférences actuelles et la fréquentation de la semaine précédente. 
    # À la fin de chaque semaine, la somme des décisions des agents donne la fréquentation totale pour cette semaine.

    for t in 1:T
        decisions = zeros(Int, N)  # Tableau pour stocker les décisions des agents cette semaine

        # Chaque agent prend une décision
        for i in 1:N
            # Ajustement aléatoire de la préférence de l'agent
            preferences[i] += rand(-preference_shift:preference_shift)
            preferences[i] = clamp(preferences[i], 0, 100) 

            # Calcul de la probabilité d'aller au bar
            if t > 1
                # Plus la préférence est proche de la fréquentation actuelle, plus l'agent est susceptible d'y aller
                prob = exp(-abs(preferences[i] - attendance[t-1]) / threshold)  
                decisions[i] = rand() < prob ? 1 : 0  
            else
                # Première semaine : décision purement aléatoire
                decisions[i] = rand() < 0.5 ? 1 : 0
            end
        end
        
        # Calcul de la fréquentation totale pour cette semaine
        attendance[t] = sum(decisions)
    end
    return attendance  # Retourne les données de fréquentation pour chaque semaine
end

# Créer un graphique de la fréquentation
function create_plot()
    attendance = generate_attendance()
    plt = plot(1:T, attendance, xlabel="Semaines", ylabel="Fréquentation",
               title="Modèle continu", legend=false)
    savefig("modele_continu.png")
end

# ----------------- Interface graphique -----------------

# Création de l'interface graphique
window = GtkWindow("Bar El Farol", 650, 450) # Fenêtre de l'application
box = GtkBox(:v)
push!(window, box)

# Zone d'affichage du graphique
canvas = GtkImage()  # Widget pour afficher des images
push!(box, canvas)

# Bouton pour relancer la simulation
restart_button = GtkButton("Relancer la simulation")
push!(box, restart_button)

# Fonction pour mettre à jour le graphique lorsque le bouton est cliqué
function update_plot()
    create_plot()  # Générer un nouveau graphique 
    set_gtk_property!(canvas, :file, "modele_continu.png")   # Charger et afficher le graphique dans la fenêtre
end

# Connecter le bouton à la fonction de mise à jour
signal_connect(restart_button, "clicked") do widget
    update_plot()
end

# Affichage initial du graphique au démarrage de l'application
update_plot()

# Afficher la fenêtre principale
showall(window)
Gtk.gtk_main()
