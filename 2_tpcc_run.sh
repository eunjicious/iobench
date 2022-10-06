

# 이렇게 하면 db table 들이 생성됨 
./sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=sysbench --mysql-user=root --mysql-password=12345 prepare


# 생성된 db table 에 io 수행하며 성능 측정. 위에서 oltp-read-only 옵션을 키고 수행하면 read 만 발생해서 빼고 실행. 그러면 write 도 함. 
# ./sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=sysbench --mysql-user=root --mysql-password=yourpassword --max-time=60 --oltp-read-only=on --max-requests=0 --num-threads=8 run

./sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=sysbench --mysql-user=root --mysql-password=yourpassword --max-time=60 --max-requests=0 --num-threads=8 run

./sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=sysbench --mysql-user=root --mysql-password=yourpassword --max-time=60 --max-requests=0 --num-threads=8 cleanup

