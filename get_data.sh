curl "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ListarProposicoesVotadasEmPlenario?ano=2015&tipo=" > proposicoes-votadas-2015.xml 
java -jar xml2csv-conv.jar proposicoes-votadas-2015.xml proposicoes-votadas-2015.csv
mkdir proposicoes
for prop in `grep -v rop proposicoes-votadas-2015.csv | cut -d, -f1`; do curl 'http://www.camara.gov.br//SitCamaraWS/Proposicoes.asmx/ObterProposicaoPorID?idProp='$prop > proposicoes/p$prop.xml; done
grep '<proposicao' proposicoes/p* | awk -F'"' '{print $2, $4, $6}' > props-tipo_numero_ano.txt 

mkdir votacoes
while read line; 
do 
	propnum=`echo $line | awk -F"[ \t\n]+" '{print $2}'`
	propurl=`echo $line | awk -F"[ \t\n]+" '{print "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=" $1 "&numero=" $2 "&ano=" $3}'`
	curl $propurl > votacoes/$propnum.xml
done < props-tipo_numero_ano.txt

#mkdir votacoes
#for propurl in `awk -F"[ \t\n]+" '{print "http://www.camara.gov.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=" $1 "&numero=" $2 "&ano=" $3}' props-tipo_numero_ano.txt`; do 
	curl $propurl > votacoes/
