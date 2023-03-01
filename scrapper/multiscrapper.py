import subprocess
import argparse
import math

def main(start, end, nbprocess):
    gap = math.floor((end-start)/nbprocess+1)

    for idProcess in range(nbprocess):
        
        start_index = start+idProcess*gap
        end_index = start_index+gap
        if end_index > end:
            end_index = end

        print(f"Download {start_index} to {end_index}...")
        
        try:
            subprocess.Popen(["python3", "./scrapper.py", str(start_index), str(end_index)], shell=False)
        except Exception as e:
            print(f"failed: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("start_index", help="Start index for exploring CSV", type=int)
    parser.add_argument("end_index", help="End index for exploring CSV", type=int)
    parser.add_argument("nb_process", help="process number", type=int)
    args = parser.parse_args()

    main(args.start_index, args.end_index, args.nb_process)