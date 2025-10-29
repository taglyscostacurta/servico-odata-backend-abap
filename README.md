🧾** Sistema de Ordem de Vendas SAP**
📘 Descrição do Projeto

Este projeto tem como objetivo o desenvolvimento de um sistema de controle de Ordens de Venda dentro do ecossistema SAP, utilizando ABAP e OData Services.
A aplicação permite o cadastro, edição, exclusão e consulta de ordens de venda e seus itens, demonstrando o uso prático de conceitos de Engenharia de Software aplicados a um ambiente corporativo real.

O sistema foi desenvolvido como parte do Projeto Integrador Transdisciplinar em Engenharia de Software II.

🎯 Objetivos

Demonstrar domínio técnico sobre modelagem de dados e desenvolvimento ABAP.
Criar uma solução funcional baseada em arquitetura REST via SAP Gateway (SEGW).
Garantir boas práticas de documentação, versionamento e testes funcionais.

⚙️ Tecnologias Utilizadas
Componente	Descrição
Linguagem	ABAP
Framework	OData (SAP NetWeaver Gateway)
Banco de Dados	SAP HANA
Front-End (opcional)	SAP Fiori / SAP Gateway Client / Postman
Plataforma	SAP S/4HANA
Controle de Versão	GitHub

🧩 Estrutura do Projeto
📂 Projeto_Ordem_Vendas_SAP/
├── 📘 1 - Projeto Sistema de Ordem de Vendas.docx
├── 📗 2 - Entidades, Relacionamento e Serviço OData.docx
├── 📙 3 - Implementação Back-End ABAP.docx
├── 📕 4 - Testes e Conclusão.docx
└── README.md

🧠 Modelagem Conceitual
Entidades Principais

OVCab (Cabeçalho da Ordem de Venda)
OrdemID
ClienteID
DataCriacao
Usuario

OVItem (Itens da Ordem de Venda)
OrdemID (chave estrangeira)
ItemID
ProdutoID
Quantidade
ValorUnitario

Relacionamento
1:N → Uma Ordem de Venda (OVCab) possui um ou mais Itens (OVItem).
Implementado via Association e Navigation Property toOVItem no serviço OData.

🔗 Principais URIs do Serviço OData
Ação	Exemplo de URI
Consultar todas as ordens	/sap/opu/odata/sap/ZOV_TAHECOLI_SRV/OVCabSet?$format=json
Consultar ordem com itens	/sap/opu/odata/sap/ZOV_TAHECOLI_SRV/OVCabSet(1)?$expand=toOVItem&$format=json
Consultar por cliente	/sap/opu/odata/sap/ZOV_TAHECOLI_SRV/OVCabSet?$filter=ClienteId eq 1234
Ordenar resultados	/sap/opu/odata/sap/ZOV_TAHECOLI_SRV/OVCabSet?$orderby=OrdemID desc
Paginar resultados	/sap/opu/odata/sap/ZOV_TAHECOLI_SRV/OVCabSet?$skip=2&$orderby=OrdemID desc
Inserir nova ordem	Método POST → /sap/opu/odata/sap/ZOV_TAHECOLI_SRV/OVCabSet
Atualizar ordem	Método PUT → /sap/opu/odata/sap/ZOV_TAHECOLI_SRV/OVCabSet(1)
Excluir ordem	Método DELETE → /sap/opu/odata/sap/ZOV_TAHECOLI_SRV/OVCabSet(1)

🧪 Testes e Resultados
Os testes foram realizados via SAP Gateway Client (/IWFND/GW_CLIENT), validando todas as operações CRUD com sucesso.

Testes Validados

✅ Criação de ordem de venda.
✅ Atualização de cabeçalho e itens.
✅ Exclusão de registros com integridade.
✅ Consulta de ordens com itens expandidos ($expand).
✅ Retorno formatado em JSON.
🗃️ Evidências

As evidências (prints de telas e código) estão disponíveis nos documentos, demonstrando:

Estrutura de tabelas (ZOVCAB_TAHECOLI e ZOVITEM_TAHECOLI).
Serviço OData ativo e funcional.
Respostas 200 OK no Gateway Client.
Execução de CRUD completa.

📈 Conclusão
O projeto demonstrou o domínio das práticas de modelagem, codificação e integração no ambiente SAP.
A abordagem ABAP + OData permitiu criar uma aplicação modular, reutilizável e alinhada com o padrão RESTful.
O tema — gestão de ordens de venda — reflete um caso de uso real do mercado, reforçando o valor prático e profissional da solução.

👤 Autor
Taglys Henrique Costacurta de Oliveira
📍 Analista ABAP Pleno – TCS
🎓 Graduando em Engenharia de Software
📧 taghcc@hotmail.com
