extends Node3D

## 🏋️ Scene2_Heavy : Scène de test pour chargement asynchrone complexe.
## Version V3 : Géométrie visible et rapport de progression intégré.

var inner_ready: bool = true # Indique à SB_Core d'attendre report_ready()
var _shared_mesh = SphereMesh.new()

func _ready() -> void:
	# On réduit un peu à 2500 pour garder une fluidité correcte en mode debug
	var total_clusters = 5
	var count_per_cluster = 500
	
	print("[SceneHeavy] Démarrage de l'initialisation de 2500 instances visibles...")
	
	for i in range(total_clusters):
		await get_tree().process_frame
		_spawn_cluster(count_per_cluster, i)
		
		var progress = (float(i + 1) / total_clusters) * 100.0
		var msg = "Initialisation GDK : %d%% (Géométrie dynamique)" % int(progress)
		
		# On log via le Core pour que ce soit visible dans la console de debug
		if SB_Core.instance:
			SB_Core.instance.log_msg(msg, "info")
			SB_Core.instance.report_progress(progress)
	
	print("[SceneHeavy] Initialisation terminée.")
	if SB_Core.instance:
		SB_Core.instance.report_ready()

func _spawn_cluster(count: int, cluster_id: int) -> void:
	var container = Node3D.new()
	container.name = "Cluster_" + str(cluster_id)
	add_child(container)
	
	var rand = RandomNumberGenerator.new()
	rand.seed = cluster_id * 1234
	
	for i in range(count):
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = _shared_mesh
		
		# Dispersion spatiale pour voir la "foule"
		var pos = Vector3(
			rand.randf_range(-20.0, 20.0),
			rand.randf_range(-10.0, 10.0),
			rand.randf_range(-20.0, 20.0)
		)
		mesh_instance.transform.origin = pos
		mesh_instance.scale = Vector3(0.2, 0.2, 0.2)
		
		container.add_child(mesh_instance)
