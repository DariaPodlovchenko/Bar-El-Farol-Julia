using Gtk
using Plots
using Random
using Statistics

# Paramètres 
N = 100                # Nombre d'agents (personnes qui décident d'aller au bar ou non)
T = 50                 # Nombre de semaines (la durée de la simulation)
seuil = 60             # Seuil de fréquentation confortable (le bar est confortable si moins de 60 personnes y vont)

# Fonction pour générer les données de fréquentation
function generate_attendance()
    attendance = zeros(Int, T)  # Tableau pour stocker le nombre de personnes au bar chaque semaine
    strategies = [rand(1:10) for _ in 1:N]  # Chaque agent choisit une stratégie au hasard parmi les 10 disponibles

    # Fonction pour définir une stratégie en fonction de l'ID
    function define_strategy(id)
        # Stratégie 1: Aller si la moyenne est basse
        if id == 1; return (history) -> length(history) > 0 && mean(history) < seuil; end  

        # Stratégie 2: Somme des 5 dernières semaines
        if id == 2; return (history) -> length(history) >= 5 && sum(history[max(1, end-4):end]) < seuil * 5; end  

        # Stratégie 3: Dernière semaine sous le seuil
        if id == 3; return (history) -> length(history) >= 1 && history[end] < seuil; end 

        # Stratégie 4: Deux dernières semaines sous le seuil
        if id == 4; return (history) -> length(history) >= 2 && all(history[max(1, end-1):end] .< seuil); end  

        # Stratégie 5: Moyenne des 10 dernières semaines
        if id == 5; return (history) -> length(history) >= 10 && mean(history[max(1, end-9):end]) < seuil; end  

        # Stratégie 6: Médiane basse
        if id == 6; return (history) -> length(history) > 0 && median(history) < seuil; end 
        
        # Stratégie 7: Décision aléatoire
        if id == 7; return (history) -> rand() < 0.5; end  

        # Stratégie 8: Minimum des 4 dernières semaines
        if id == 8; return (history) -> length(history) >= 4 && minimum(history[max(1, end-3):end]) < seuil; end  

        # Stratégie 9: Différence faible entre max et min
        if id == 9; return (history) -> length(history) >= 4 && (maximum(history[max(1, end-3):end]) - minimum(history[max(1, end-3):end])) < seuil / 2; end  

        # Stratégie 10: Moyenne des 7 dernières semaines
        if id == 10; return (history) -> length(history) >= 7 && mean(history[max(1, end-6):end]) < seuil; end  
    end

    # Attribution des stratégies à chaque agent
    agent_strategies = [define_strategy(s) for s in strategies]

    # Simulation de la fréquentation chaque semaine
    for t in 1:T
        # Chaque agent prend une décision en fonction de sa stratégie et de l'historique des semaines précédentes
        decisions = [agent_strategies[i](attendance[1:t-1]) for i in 1:N]

        # Nombre total de personnes qui décident d'aller au bar cette semaine
        attendance[t] = sum(decisions)
    end
    return attendance
end

# Créer un graphique de la fréquentation
function create_plot()
    attendance = generate_attendance()  # Générer les données de fréquentation
    plt = plot(1:T, attendance, xlabel="Semaines", ylabel="Fréquentation",
               title="Modèle discret", legend=false)
    savefig("modele_discret.png")  # Sauvegarder le graphique dans un fichier PNG
end

# --------------- Interface graphique ----------------

# Création de l'interface graphique
window = GtkWindow("Bar El Farol", 650, 450)  # Fenêtre de l'application
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
    set_gtk_property!(canvas, :file, "modele_discret.png")  # Charger et afficher le graphique dans la fenêtre
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
