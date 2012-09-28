function convertir_en_piece(t, r, c) --Type, Rotation, Centre {y, x}
	local p = {{c[1], c[2]}, {c[1], c[2]}, {c[1], c[2]}, {c[1], c[2]}}
	
	if t >= 1 and t <= 7 then
		for s = 1, 4 do
			if r == 0 then
				p[s] = {pieces[t][s][1] + c[1], pieces[t][s][2] + c[2]}
			elseif r == 90 then
				p[s] = {pieces[t][s][2] + c[1], -pieces[t][s][1] + c[2]}
			elseif r == 180 then
				p[s] = {-pieces[t][s][1] + c[1], -pieces[t][s][2] + c[2]}
			elseif r == 270 then
				p[s] = {-pieces[t][s][2] + c[1], pieces[t][s][1] + c[2]}
			end
		end
	end
	
	return p
end

--fonction qui efface les lignes pleines
function modification_matrice()
	local nb_ligne = 0
	--boucle de test ligne
	for y =  1, matrice_hauteur  do
		for x = 1, matrice_largeur do
			if matrice[y][x] == 0 then
				break
			elseif 	x == 7 then
				nb_ligne = nb_ligne + 1
				--boucle de mise à jour matrice
				for m = y-1, 1, - 1 do
					for n = 1, matrice_largeur do
						--décale la ligne superieur sur la ligne inferieur
						matrice[m + 1][n] = matrice[m][n]
					end
				end
			end
		end
	end
	return nb_ligne
end

--fonction de comptage des points
function compteur_point(nb_ligne)
	local score
	score = 0
	if nb_ligne == 0 then
		score = 0
	elseif nb_ligne == 1 then
		score = 1
	elseif nb_ligne == 2 then
		score = 2
	elseif nb_ligne == 3 then
		score = 5
	elseif nb_ligne == 4 then
		score = 10
	end
	score_tetris = score_tetris + score
	compteur_de_temps_maximum = compteur_de_temps_coefficient * compteur_de_temps_maximum --prochain tour plus rapide en attendant la gestion des lignes / score / niveaux...
end

function suis_je_hors_limite(p, y, x) --Piece, offset Y, offset X
	for s = 1, 4 do
		if p[s][1] + y <= 0 or p[s][1] + y > matrice_hauteur or p[s][2] + x <= 0 or p[s][2] + x > matrice_largeur then
			return true --si un des blocs de la pièce est en dehors de la matrice, la réponse est oui
		end
	end
	
	return false --si on arrive jusqu'ici, la réponse est non
end

function puis_je_mettre_la_piece_sur_la_matrice(m, p, y, x) --matrice, Piece, offset Y, offset X
	for s = 1, 4 do
		if m[p[s][1] + y][p[s][2] + x] ~= 0 then
			return false --si la matrice contient déjà quelque chose à un des blocs de la pièce, la réponse est non
		end
	end
	
	return true --si on arrive jusqu'ici, la réponse est oui
end

function decale_la_piece(p, y, x) --Piece, offset Y, offset X
	for s = 1, 4 do
		p[s] = {p[s][1] + y, p[s][2] + x}
	end
	
	return p
end

function ecrit_la_piece_sur_la_matrice(m, p, t) --matrice, Piece, Type
	for s = 1, 4 do
		m[p[s][1]][p[s][2]] = t
	end
	
	return m
end
