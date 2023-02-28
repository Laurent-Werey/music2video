from pychorus import create_chroma
from pychorus.helpers import local_maxima_rows, detect_lines, count_overlapping_lines
from pychorus.similarity_matrix import TimeTimeSimilarityMatrix, TimeLagSimilarityMatrix
from pychorus.constants import SMOOTHING_SIZE_SEC, OVERLAP_PERCENT_MARGIN
import soundfile as sf

"""
    Morceaux de test
"""
path = "chorus/audio-files/"
input_file = "n3UBSa7-H0U.mp3"
# input_file = "5qm8PH4xAss.mp3"
# input_file = "K0HSD_i2DvA.mp3"


"""
    Génère les notes présentes dans le morceau -> chromagramme

    Le chromagramme est découpé en 5 extraits par seconde.
    Chaque extrait (0.2sec) est un vecteur de 12 éléments avec des valeurs entre 0 et 1,
    ces 12 éléments correspondent aux différentes notes à l'échelle occidentale.
    Si le morceau est silencieux le vecteur ne contiendrait que des 0. 

    Par exemple :
        Pour un morceau de 4min (240sec), le chromagramme serait une matrice de :
        12 (notes à l'échelle occidentale) * ( 240 (durée du morceau en secondes) * 5 (nombre d'extraits par seconde) )
        = 12 * 1200 

    Retourne :
    - chroma : une matrice de 12 * n, où n = durée du morceau en secondes * 5 
    - song_wav_data : données wav du morceau
    - sr : fréquence d'échantillonnage, généralement 22050
    - song_length_sec : durée du morceau en secondes
"""
chroma, song_wav_data, sr, song_length_sec = create_chroma(path+input_file)


"""
    Trouve les similarités dans le morceau

    Paramètres :
    - clip_length: longueur minimale en secondes du refrain (au moins 10-15s)

    Retourne : 
    - Dictionnaire de lignes de la forme :
        {Line (début fin décalage): correspondance refrain, ...}
"""
def find_similiraties(clip_length):
    num_samples = chroma.shape[1]

    time_time_similarity = TimeTimeSimilarityMatrix(chroma, sr)
    time_lag_similarity = TimeLagSimilarityMatrix(chroma, sr)

    # Débruitage de la matrice de décalage temporel
    chroma_sr = num_samples / song_length_sec
    smoothing_size_samples = int(SMOOTHING_SIZE_SEC * chroma_sr)
    time_lag_similarity.denoise(time_time_similarity.matrix,
                                smoothing_size_samples)

    # Détecte les lignes dans l'image
    clip_length_samples = clip_length * chroma_sr
    candidate_rows = local_maxima_rows(time_lag_similarity.matrix)
    lines = detect_lines(time_lag_similarity.matrix, candidate_rows,
                            clip_length_samples)
    if len(lines) == 0:
        print("No choruses were detected. Try a smaller search duration")
        return None

    line_scores = count_overlapping_lines(
        lines, OVERLAP_PERCENT_MARGIN * clip_length_samples,
        clip_length_samples)

    for line in line_scores:
        line.start = int(line.start / chroma_sr)
        line.end = int(line.end / chroma_sr)

    return line_scores


"""
    Trouve le ou les refrains les plus répétés 

    Paramètres :
    - clip_length: longueur minimale en secondes du refrain (au moins 10-15s)

    Retourne : 
    - Tableau de lignes de la forme :
        [(Line (début fin décalage), correspondance refrain), ...]
"""
def find_chorus(clip_length):
    line_scores = find_similiraties(clip_length)
    chorus_values = []
    for line in line_scores:
        chorus_values.append(line_scores[line])
    chorus_value = max(chorus_values)
    chorus = []
    for line in line_scores:
        if line_scores[line] == chorus_value:
            chorus.append((line,line_scores[line]))
    
    return chorus


"""
    Affiche le ou les refrains les plus répétés 

    Paramètres :
    - clip_length: longueur minimale en secondes du refrain (au moins 10-15s)
"""
def print_chorus(clip_length):
    chorus = find_chorus(clip_length)
    print('Chorus:',chorus)


"""
    Trouve le ou les refrains les plus répétés et les transmets au fichier de sortie
    Affiche le ou les refrains les plus répétés 

    Paramètres :
    - output_file : nom du fichier de sortie 
    - clip_length: longueur minimale en secondes du refrain (au moins 10-15s)
"""
def output_chorus(output_file, clip_length=15):
    chorus = find_chorus(clip_length)
    output_file_number = 0
    for cho in chorus:
        if output_file is not None:
            output_file_number += 1
            chorus_wave_data = song_wav_data[int(cho[0].start*sr) : int((cho[0].start+clip_length)*sr)]
            sf.write(path+'outputs/ch_'+str(output_file_number)+'_'+output_file, chorus_wave_data, sr)
    print_chorus(clip_length)


# Test 
output_chorus(input_file,15)