#curl --connect-timeout 15 --retry 5 --keepalive-time 10 "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ListarProposicoesVotadasEmPlenario?ano=2015&tipo=" > ../dados/proposicoes-votadas.xml
#curl --connect-timeout 15 --retry 5 --keepalive-time 10 "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ListarProposicoesVotadasEmPlenario?ano=2016&tipo=" >> ../dados/proposicoes-votadas.xml 


java -jar xml2csv-conv.jar ../dados/proposicoes-votadas.xml ../dados/proposicoes-votadas.csv
mkdir ../dados/proposicoes
for prop in `grep -v rop ../dados/proposicoes-votadas.csv | cut -d, -f1`; 
do 
	if [ ! -f ../dados/proposicoes/p$prop.xml ]; 
	then 
		curl --connect-timeout 15 --retry 5 --keepalive-time 10 'http://www.camara.gov.br//SitCamaraWS/Proposicoes.asmx/ObterProposicaoPorID?idProp='$prop > ../dados/proposicoes/p$prop.xml; 
		sleep 3;
	fi
done

grep '<proposicao ' ../dados/proposicoes/p* | awk -F'"' '{print $2, $4, $6}' > ../dados/props-tipo_numero_ano.txt 

mkdir ../dados/votacoes
while read line; 
do 
	propnum=`echo $line | awk -F"[ \t\n]+" '{print $2}'`
	if [ ! -f ../dados/votacoes/$propnum.xml ]; then 
		propurl=`echo $line | awk -F"[ \t\n]+" '{print "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=" $1 "&numero=" $2 "&ano=" $3}'`
		curl --connect-timeout 15 --retry 5 --keepalive-time 10 $propurl > ../dados/votacoes/$propnum.xml
		sleep 3;
	fi 
done < ../dados/props-tipo_numero_ano.txt

mkdir ../dados/deputados
curl --connect-timeout 15 --retry 5 --keepalive-time 10 "http://www.camara.gov.br/SitCamaraWS/Deputados.asmx/ObterDeputados" > ../dados/deputados/deputados.xml


