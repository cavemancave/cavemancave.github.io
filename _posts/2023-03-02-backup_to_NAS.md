

sudo mount.cifs //192.168.0.6/Users/taishan/Documents/XGH/NAS/ /home/taishan/video -o user=taishan

ls -l video/

rsync -avzn /home/taishan/video/ taishan@192.168.0.5:/volume1/photo |more


rsync -avz /home/taishan/video/ taishan@192.168.0.5:/volume1/photo