require 'rest-client'
require 'base64'
require "uri"
require "net/http"
require "byebug"
require 'json'
require 'time'
require 'active_support/time'
require 'write_xlsx'


$url_shop = "http://idealsoftexportaweb.eastus.cloudapp.azure.com:60500".freez

def token
    url = URI("#{$url_shop}/auth/?serie=HIEAPA-600759-ROCT&codfilial=2")

    http = Net::HTTP.new(url.host, url.port);
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "Basic dGVzdHVzZXI6cGFzc3dvcmRAMTIz"
    request["Content-Type"] = "application/json"

    response = http.request(request)
    return JSON.parse(response.body)['dados']['token']
end


def venda
    return {"CodigoCliente": "249","CodigoOperacao": "500","cpfCnpj": "39622286755","codigoCaixa": 1,"data": "2021-09-10 09:47:39 -0300","Observacao": "Zerado","Desconto_Total_Geral": 0.0,"CodigoVendedor_1": 1,"CodigoVendedor_2": 2,"produtos":[{"codigo": "3","codigoCor": "1","codigoTamanho": "1","quantidade": 1.0,"precoUnitario": 10.52,"descontoUnitario": 0.0}],"recebimentos":[{"valorParcelas": 10.52,"valor": 10.52,"codigoContaBancaria": 20,"vencimento": "2021-09-11 09:47:39 -0300","codigoAdministradora":1,"nsu": "123","quantidadeParcelas":1,"numeroCartao": "2344","tipo": "C"}],"dadosEntrega":{"valor": 0.0,"opcoesFretePagoPor": "E","pesoBruto": 0.0,"pesoLiquido": 0.0,"volume": 0.0,"dataEntrega": "2021-09-17 09:47:39 -0300","cnpjTransportadora": nil,"naoSomarFreteTotalNota": true,"outroEndereco":{"cep": "74345220","endereco": "Rua Francisco Godinho","numero": "171","complemento": "Residencial Ecovitta","bairro": "Vila Rosa","cidade": "Goiania","uf": "GO"}}}
end

def cliente
    return { "Nome": "Bruno Neville Ribeiro Santos", "Fantasia": "Upper Desenvolvimento", "Tipo": "C", "FisicaJuridica": "F", "CpfCnpj": "05553514169", "Rg": "179810467", "Ie": "ISENTO", "Cep": 82515000, "Endereco": "Av. Pref. Erasto Gaertner", "Numero": 2500, "Complemento": "Bl 131", "Bairro": "Bacacheri", "Cidade": "Curitiba", "Uf": "PR", "Pais": "", "Telefone1": "41992279389", "Telefone2": nil, "Fax": nil, "EntregaCep": nil, "EntregaEndereco": nil, "EntregaNumero": nil, "EntregaComplemento": nil, "EntregaBairro": nil, "EntregaCidade": nil, "EntregaUf": nil, "EntregaPais": nil, "EntregaPontoRef1": nil, "EntregaPontoRef2": nil, "FaturamentoCep": nil, "FaturamentoEndereco": nil, "FaturamentoNumero": nil, "FaturamentoComplemento": nil, "FaturamentoBairro": nil, "FaturamentoCidade": nil, "FaturamentoUf": nil, "FaturamentoPais": nil, "FaturamentoPontoRef1": nil, "FaturamentoPontoRef2": nil }
end



$token = "Token #{token()}"


$time = (Time.now + 3.hours).to_i.to_s
body = Base64.strict_encode64(cliente().to_json)
$key = "senha"
$metodo = "get"
$data = $metodo + $time

$signature = Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), $key, $data))
#$signature = Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), $key, $data)).strip()

#Get CLIENTES

#clientes = RestClient.get("#{$url_shop}/produtos/1", header={'Authorization': "#{$token}", 'Signature': "#{$signature}", 'CodFilial': '2', 'Timestamp': "#{$time}"})
workbook = WriteXLSX.new('produtos.xlsx')

ind = 1

row = 1

worksheet = workbook.add_worksheet

worksheet.write(0, 0, "Nome")
worksheet.write(0, 1, "Codigo")
worksheet.write(0, 2, "Grupo")


while ind <= 10000000 do
    puts "AQUI"
    url = URI("#{$url_shop}/produtos/#{ind}")

    http = Net::HTTP.new(url.host, url.port);
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = $token
    request["signature"] = $signature
    request["CodFilial"] = "2"
    request["Timestamp"] = $time
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"

    response = http.request(request)
    return_resp = JSON.parse(response.read_body)

    if return_resp['tipo'] == "FIM_DE_PAGINA"
        puts "ULTIMA PAGINA"
        puts ind
        ind = 10000001
    else

        return_resp['dados'].each do |produto|
            worksheet.write(row, 0, produto['nome'])
            worksheet.write(row, 1, produto['codigo'])
            worksheet.write(row, 2, produto['codigoGrupo'])
            row += 1
        end

        ind += 1
    end

end


workbook.close
debugger
x = 1
