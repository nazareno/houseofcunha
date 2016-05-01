curl "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ListarProposicoesVotadasEmPlenario?ano=2016&tipo=" > proposicoes-votadas-2016.xml 
java -jar xml2csv-conv.jar proposicoes-votadas-2016.xml proposicoes-votadas-2016.csv
mkdir proposicoes
for prop in `grep -v rop proposicoes-votadas-2016.csv | cut -d, -f1`; 
do 
	if [ ! -f proposicoes/p$prop.xml ]; 
	then 
		curl 'http://www.camara.gov.br//SitCamaraWS/Proposicoes.asmx/ObterProposicaoPorID?idProp='$prop > proposicoes/p$prop.xml; 
	fi
done

grep '<proposicao ' proposicoes/p* | awk -F'"' '{print $2, $4, $6}' > props-tipo_numero_ano.txt 

mkdir votacoes
while read line; 
do 
	propnum=`echo $line | awk -F"[ \t\n]+" '{print $2}'`
	if [ ! -f votacoes/$propnum.xml ]; then 
		propurl=`echo $line | awk -F"[ \t\n]+" '{print "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=" $1 "&numero=" $2 "&ano=" $3}'`
		echo $propurl
		curl $propurl > votacoes/$propnum.xml
	fi 
done < props-tipo_numero_ano.txt

