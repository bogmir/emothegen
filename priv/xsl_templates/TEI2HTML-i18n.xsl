<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output indent="yes"/>
    <!--VARIABLES-->
    <xsl:variable name="idioma" select="//tei:language/@ident"/>
    <xsl:param name="pLang" select="substring($idioma,1,2)"/>

    <xsl:variable name="labels" select="document('Emothe_labels.xml')/labels"/>
    <xsl:variable name="metrica" select="document('Metrica_labels.xml')/metrica"/>

    <xsl:variable name="editorc60" select="//tei:editor[@role='canon60']"/>

    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <xsl:variable name="label_digital_editor" select="$labels/digital_editor[@lang = $pLang]"/>
    <xsl:variable name="label_adaptacion_digital" select="$labels/adaptacion_digital[@lang = $pLang]"/>

    <!--..................TEI PRINCIPAL............-->
    <xsl:template match="tei:TEI">
        <html>
            <head>
                <title>
                    <xsl:choose>
                        <!-- Cuando es una traducción -->
                        <xsl:when test="//tei:titleStmt/tei:title[@type='traduccion']">
                            <xsl:value-of select="//tei:titleStmt/tei:title"/>
                            <xsl:text> / </xsl:text>
                            <xsl:value-of select="//tei:titleStmt/tei:author[1]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="//tei:editor/tei:persName"/>
                            <xsl:text> (tra.)</xsl:text>
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="$label_adaptacion_digital"/>
                        </xsl:when>
                        <!-- Cuando es una edición (no traducción) -->
                        <xsl:otherwise>
                            <xsl:value-of select="//tei:titleStmt/tei:title"/>
                            <xsl:text> / </xsl:text>
                            <xsl:value-of select="//tei:titleStmt/tei:author[1]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="//tei:editor/tei:persName"/>
                            <xsl:text> (ed.)</xsl:text>
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="$label_adaptacion_digital"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </title>
                <xsl:processing-instruction name="php">include_once 'includes_cabecera.php'<xsl:text>?</xsl:text>
                </xsl:processing-instruction>
            </head>
            <body>
                <!-- Accedemos a la cabecera para generar la "portada" -->
                <xsl:apply-templates select="tei:teiHeader"/>
                <!-- Recorremos los nodos en modo normal para generar el texto -->
                <xsl:apply-templates select="tei:text" />
            </body>
        </html>
    </xsl:template>
    <!--.................................................-->


    <!--..................PORTADA........................-->
    <!-- Para generar la "portada" -->
    <xsl:template match="tei:teiHeader">
        <div id="cabecera_portal">
            <xsl:variable name="nombreFichero" select="tei:fileDesc/tei:titleStmt/tei:title[@key='archivo']"/>
            <xsl:if test="(substring($nombreFichero,1,2)='AL')">
                <img src="../images/logo_biblioteca_artelope_lope.png" width="179" height="120" style="position:fixed; top:0;left: 0;"/>
            </xsl:if>
            <xsl:if test="(substring($nombreFichero,1,2)='EM')">
                <img src="../images/logo_biblioteca_artelope_emothe.png" width="179" height="120" style="position:fixed; top:0;left: 0;"/>
            </xsl:if>
            <xsl:if test="(substring($nombreFichero,1,2)='C6')">
                <img src="images/logo_biblioteca_canon60.png" width="179" height="120" style="position:fixed; top:0;left: 0;"/>
            </xsl:if>

            <div id="tit_cab">
                <xsl:choose>
                    <!-- Cuando es una traducción -->
                    <xsl:when test="tei:fileDesc/tei:titleStmt/tei:title[@type='traduccion']">
                        <h2 id="autor">
                            <xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:author[1]"/>
                            <xsl:text>, </xsl:text>
                            <span style="text-transform:uppercase;">
                                <xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title[@type='original']"/>
                            </span>
                        </h2>
                        <h1 id="titPrincipal">
                            <xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title[1]" />
                        </h1>
                        <hr class="sigilChapterBreak"/>
                        <div id="subtit">
                            <!-- Datos de traducción -->
                        </div>
                        <hr class="sigilChapterBreak"/>
                    </xsl:when>
                    <!-- Cuando es una adaptación -->
                    <xsl:when test="tei:fileDesc/tei:titleStmt/tei:title[@type='adaptacion']">
                        <h2 id="autor">
                            <xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:author[@key='original']"/>
                            <xsl:text>, </xsl:text>
                            <span style="text-transform:uppercase;">
                                <xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title[@type='original']"/>
                            </span>
                        </h2>
                        <h1 id="titPrincipal">
                            <xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title[@type='adaptacion']"/>
                        </h1>
                        <hr class="sigilChapterBreak"/>
                        <div id="subtit">
                            <!-- Datos de refundición -->
                        </div>
                        <hr class="sigilChapterBreak"/>
                    </xsl:when>
                    <!-- Cuando es un titulo principal o "unico" -->
                    <xsl:otherwise>
                        <h2 id="autor">
                            <xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:author[1]"/>
                        </h2>
                        <h1 id="titPrincipal">
                            <xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title[1]" />
                        </h1>
                        <hr class="sigilChapterBreak"/>
                        <!-- Si es de EMOTHE añadir una franja -->
                        <xsl:if test="(substring($nombreFichero,1,2)='EM')">
                            <div id="subtit">
                            </div>
                            <hr class="sigilChapterBreak"/>
                        </xsl:if>

                    </xsl:otherwise>
                </xsl:choose>
            </div>
            <xsl:apply-templates select="../tei:text" mode="toc"/>
        </div>
    </xsl:template>
    <!--.................................................-->

    <!--..................INDICE.........................-->
    <!-- Para generar el índice -->
    <xsl:template match="tei:text" mode="toc">
        <xsl:variable name="nombreFichero" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@key='archivo']"/>
        <div id="menu_herramientas">

            <div id="b_panel">
                <span onClick="mostrarPanel(0)">
                    <xsl:value-of select="$labels/cerrar_panel[@lang=$pLang]"/>
                </span>
            </div>

            <div id="panel">
                <span id="linea_tools">
                    <strong>
                        <xsl:value-of select="$labels/indice_navegacion[@lang = $pLang]"/>
                    </strong>
                </span>
                <br/>
                <a href="#metadatos">
                    <xsl:value-of select="$labels/datos_edicion[@lang = $pLang]"/>
                </a>
                <br/>

                <!--HEADER LINKS -->
                <xsl:for-each select="tei:front/tei:div">
                    <xsl:variable name="etiquetaParatexto">
                        <xsl:value-of select="@type"/>
                    </xsl:variable>
                    <xsl:variable name="headerParatexto">
                        <xsl:if test="tei:head and tei:head!=''">
                            <xsl:value-of select="tei:head"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="($etiquetaParatexto = 'elenco' or 
                            $etiquetaParatexto = 'prologo' or 
                            $etiquetaParatexto = 'dedicatoria' or 
                            $etiquetaParatexto ='indicaciones' or 
                            $etiquetaParatexto ='colofon' or 
                            $etiquetaParatexto ='despedida' or 
                            $etiquetaParatexto ='licencia' or 
                            $etiquetaParatexto ='epistola' or 
                            $etiquetaParatexto ='noticia_representacion' or 
                            $etiquetaParatexto ='argumento' or 
                            $etiquetaParatexto ='introduccion_autor' or 
                            $etiquetaParatexto ='introduccion_traductor' or 
                            $etiquetaParatexto ='introduccion_editor' or 
                            $etiquetaParatexto ='introduccion_editor_digital' or 
                            $etiquetaParatexto ='loa' or
                            $etiquetaParatexto ='letra' or
                            $etiquetaParatexto ='sarao' or
                            $etiquetaParatexto ='nota_edicion_digital' or
                            $etiquetaParatexto ='apendice' or
                            $etiquetaParatexto ='aparato_critico' or
                            $etiquetaParatexto ='bibliografia' )">
                            <a href="#{$etiquetaParatexto}">
                                <xsl:choose>
                                    <xsl:when test="tei:head and tei:head!=''">
                                        <xsl:value-of select="$headerParatexto"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>[</xsl:text>
                                        <xsl:value-of select="$labels/*[local-name() = $etiquetaParatexto][@lang = $pLang]"/>
                                        <xsl:text>]</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <br/>
                            </a>
                        </xsl:when>
                        <!--<xsl:otherwise>
                            <xsl:text>Otro_tipo</xsl:text>
                        </xsl:otherwise>-->
                    </xsl:choose>
                </xsl:for-each>

                <!-- BODY LINKS-->
                <xsl:for-each select="tei:body/tei:div1">
                    <xsl:variable name="tipoSeccion">
                        <xsl:value-of select="@type"/>
                    </xsl:variable>
                    <xsl:variable name="etiquetaActo">
                        <xsl:value-of select="$tipoSeccion"/>
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="@n"/>
                    </xsl:variable>

                    <a href="#{$etiquetaActo}">
                        <xsl:choose>
                            <xsl:when test="tei:head and tei:head!=''">
                                <xsl:value-of select="concat(translate(substring(tei:head, 1, 1), $lowercase, $uppercase), substring(tei:head, 2))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="$tipoSeccion='act'">
                                    <xsl:value-of select="$labels/act[@lang = $pLang]"/>
                                    <xsl:text></xsl:text>
                                    <xsl:value-of select="@n"/>
                                </xsl:if>
                                <xsl:if test="$tipoSeccion!='act'">
                                    <xsl:value-of select="concat(translate(substring($tipoSeccion, 1, 1), $lowercase, $uppercase), substring($tipoSeccion, 2))"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                    <br/>
                </xsl:for-each>

                <!--FOOTER LINKS -->
                <xsl:for-each select="tei:back/tei:div">
                    <xsl:variable name="etiquetaParatexto">
                        <xsl:value-of select="@type"/>
                    </xsl:variable>
                    <xsl:variable name="headerParatexto">
                        <xsl:if test="tei:head and tei:head!=''">
                            <xsl:value-of select="concat(translate(substring(tei:head, 1, 1), $lowercase, $uppercase), substring(tei:head, 2))"/>
                        </xsl:if>
                    </xsl:variable>

                    <a href="#{$etiquetaParatexto}">
                        <xsl:choose>
                            <xsl:when test="tei:head and tei:head!=''">
                                <xsl:value-of select="$headerParatexto"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>[</xsl:text>
                                <xsl:value-of select="$labels/*[local-name() = $etiquetaParatexto][@lang = $pLang]"/>
                                <xsl:text>]</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                    <br/>
                </xsl:for-each>

                <!-- Display features -->
                <hr/>
                <span id="linea_tools">
                    <strong>
                        <xsl:value-of select="$labels/marcas_visuales[@lang = $pLang]"/>
                    </strong>
                </span>

                <!-- Mostrar cada -->
                <p>
                    <label>
                        <xsl:value-of select="$labels/no_lineas[@lang = $pLang]"/>
                        <br/>
                        <span id="etiquetaVersos" onClick="Resaltar('numLineas')">
                            <xsl:value-of select="$labels/mostrar_cada[@lang = $pLang]"/>
                        </span>
                    </label>
                </p>

                <!-- Acotaciones -->
                <p>
                    <label>
                        <input type="checkbox" id="acotaciones" onClick="Resaltar('acotacion')"/>
                        <span id="etiquetaAcotacion">
                            <xsl:value-of select="$labels/acotaciones[@lang = $pLang]"/>
                        </span>
                    </label>
                    <div id="resumenAcotaciones"></div>
                </p>

                <!-- Apartes -->
                <xsl:if test="(substring($nombreFichero,1,2)!='C6')">
                    <p>
                        <label>
                            <input type="checkbox" id="apartes" onClick="Resaltar('aparte')"/>
                            <span id="etiquetaAparte">
                                <xsl:value-of select="$labels/apartes[@lang = $pLang]"/>
                            </span>
                        </label>
                        <div id="resumenApartes"></div>
                    </p>
                </xsl:if>

                <xsl:variable name="extent">
                    <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:extent/@ana"/>
                </xsl:variable>

                <!-- Si el texto es en verso -->
                <!--<xsl:if test="contains($extent,'verso')">-->
                <xsl:if test="$extent='verso'">
                    <!-- Versos partidos -->
                    <p>
                        <label>
                            <input type="checkbox" id="truncados" onClick="Resaltar('truncados')"/>
                            <span id="etiquetaTruncados">
                                <xsl:value-of select="$labels/versos_partidos[@lang = $pLang]"/>
                            </span>
                        </label>
                        <div id="resumenTruncados"></div>
                    </p>
                </xsl:if>

                <xsl:if test="$extent='linea'">
                    <p>
                        <xsl:value-of select="$labels/def_tipo_linea[@lang = $pLang]"/>
                    </p>
                </xsl:if>

                <!-- METRICA -->
                <xsl:if test="(substring($nombreFichero,1,2)!='C6') and (($idioma='es-ES') or ($idioma='pt-PT'))">
                    <label>
                        <input type="checkbox" id="mostrarMetrica" onClick="funcionMetrica()" />
                        <div id="muestra_metrica">
                            <xsl:value-of select="$labels/mostrar_metrica[@lang = $pLang]"/>
                        </div>
                    </label>
                </xsl:if>

                <hr/>

                <!-- ESTADÍSTICAS -->
                <span id="linea_tools">
                    <strong>
                        <xsl:element name="a">
                            <xsl:attribute name="id">
                                <xsl:text>boton_herramientas</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:text>./estadisticas/</xsl:text>
                                <xsl:value-of select="$nombreFichero"/>
                                <xsl:text>.html</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="rel">
                                <xsl:text>gb_page_center[600,600]</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="title">
                                <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]"/>
                                <xsl:text> - </xsl:text>
                                <xsl:value-of select="$labels/estadisticas[@lang = $pLang]"/>
                                <!-- - STATISTICS-->
                            </xsl:attribute>
                            <input name="estadisticas" id="estadisticas" type="button" value="{$labels/estadisticas[@lang = $pLang]}"/>
                        </xsl:element>
                    </strong>
                </span>

                <!-- ETIQUETAS -->
                <xsl:if test="(substring($nombreFichero,1,2)='EM') and //*[name()='rs']">
                    <span id="linea_tools">
                        <strong>
                            <xsl:element name="a">
                                <xsl:attribute name="id">
                                    <xsl:text>boton_herramientas</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="href">
                                    <xsl:text>./notas/</xsl:text>
                                    <xsl:value-of select="$nombreFichero"/>
                                    <xsl:text>.html</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="rel">
                                    <xsl:text>gb_page_center[600,600]</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="title">
                                    <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]"/>
                                    <xsl:text> - </xsl:text>
                                    <xsl:value-of select="$labels/etiquetas[@lang = $pLang]"/>
                                    <!-- - TAGGED FEATURES-->
                                </xsl:attribute>
                                <input name="estadisticas" id="estadisticas" type="button" value="{$labels/etiquetas[@lang = $pLang]}"/>
                            </xsl:element>
                        </strong>
                    </span>
                </xsl:if>
            </div>
        </div>

        <hr class="sigilChapterBreak"/>
    </xsl:template>
    <!--.................................................-->


    <!--....................TEXTO.........................-->
    <!-- Recorremos el texto -->
    <xsl:template match="tei:text">
        <div id="content" class="obra">
            <div id="text">
                <xsl:apply-templates select="tei:front" />
                <xsl:apply-templates select="tei:body" />
                <xsl:apply-templates select="tei:back" />
            </div>
        </div>
    </xsl:template>
    <!--.................................................-->

    <!--.......................PARATEXTOS PREVIOS.......................-->
    <!-- Recorremos los paratextos previos -->
    <xsl:template match="tei:front">
        <xsl:variable name="nombreFichero" select="//tei:title[@key='archivo']"/>
        <div id="front">
            <!-- Comun a todos los textos: edición e investigadores -->
            <p class="posicion_ancla">
                <a name="metadatos"></a>
            </p>
            <div id="metadatos">
                <!--<xsl:text>Edición digital a partir de </xsl:text>-->
                <xsl:if test="(substring($nombreFichero,1,2)!='C6')">
                    <xsl:variable name="fiabilibad" select="//tei:author/@ana" />
                    <br/>
                    <xsl:if test="$fiabilibad='fiable'">
                        <!--Fiable-->
                    </xsl:if>
                    <xsl:if test="$fiabilibad='probable' or $fiabilibad='dudosa' or $fiabilibad='inautentica'">
                        <strong>
                            <xsl:value-of select="$labels/autoria[@lang = $pLang]"/>
                        </strong>
                        <xsl:value-of select="$labels/*[local-name() = $fiabilibad][@lang = $pLang]"/>
                        <br/>
                    </xsl:if>
                </xsl:if>

                <strong>
                    <xsl:value-of select="$labels/texto_utilizado[@lang = $pLang]"/>
                </strong>
                <br/>
                <xsl:apply-templates select="//tei:bibl/tei:note"/>
            </div>

            <div id="investigadores">
                <xsl:if test="(substring($nombreFichero,1,2)!='C6')">
                    <xsl:if test="$editorc60">
                        <strong>
                            <xsl:value-of select="concat(translate(substring($label_adaptacion_digital, 1, 1), $lowercase, $uppercase), substring($label_adaptacion_digital, 2))"/>
                        </strong>
                        <br/>
                    </xsl:if>
                    <xsl:if test="not($editorc60)">
                        <xsl:if test="(substring($nombreFichero,1,2)='EM')">
                            <strong>
                                <xsl:value-of select="$label_digital_editor"/>
                                <xsl:text> EMOTHE:</xsl:text>
                            </strong>
                            <br/>
                        </xsl:if>
                        <xsl:if test="(substring($nombreFichero,1,2)='AL')">
                            <strong>
                                <xsl:value-of select="$label_digital_editor"/>
                                <xsl:text> ARTELOPE:</xsl:text>
                            </strong>
                            <br/>
                        </xsl:if>
                    </xsl:if>
                    <ul>
                        <xsl:for-each select="//tei:respStmt/tei:persName">
                            <li>
                                <xsl:value-of select="."/>
                                <xsl:if test="tei:orgName!=''">
                                    <xsl:text> (</xsl:text>
                                    <xsl:value-of select="tei:orgName"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:if>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="(substring($nombreFichero,1,2)='C6')">
                    <strong>
                        <xsl:value-of select="$labels/cargo_edicion[@lang = $pLang]"/>
                    </strong>
                    <br/>
                    <xsl:value-of select="../../tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt/tei:orgName"/>
                </xsl:if>
            </div>

            <!-- Cada paratexto -->

            <xsl:for-each select="tei:div">
                <xsl:variable name="etiquetaParatexto">
                    <xsl:value-of select="@type"/>
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test="$etiquetaParatexto = 'title_page'">
                        <xsl:variable name="cabecera">
                            <xsl:value-of select="tei:head"/>
                        </xsl:variable>
                        <!--TOASK: id debería ser 'title_page'?-->
                        <div id="argumento" class="paratextos">
                            <a name="{@type}"></a>
                            <h1>
                                <xsl:for-each select="./*">
                                    <xsl:if test="name()!='head'">
                                        <xsl:apply-templates select="."/>
                                    </xsl:if>
                                </xsl:for-each>
                            </h1>
                        </div>
                    </xsl:when>
                    <xsl:when test="$etiquetaParatexto ='head_title'">
                        <xsl:variable name="cabecera">
                            <xsl:value-of select="tei:head"/>
                        </xsl:variable>
                        <div id="head_title" class="paratextos">
                            <a name="{@type}"></a>
                            <h1>
                                <xsl:for-each select="./*">
                                    <xsl:if test="name()!='head'">
                                        <xsl:apply-templates select="."/>
                                    </xsl:if>
                                </xsl:for-each>
                            </h1>
                        </div>
                    </xsl:when>

                    <xsl:when test="($etiquetaParatexto = 'dedicatoria' or 
                            $etiquetaParatexto ='prologo' or  
                            $etiquetaParatexto ='circunstancia_accion' or 
                            $etiquetaParatexto ='epistola' or 
                            $etiquetaParatexto ='noticia_representacion' or 
                            $etiquetaParatexto ='argumento' or 
                            $etiquetaParatexto ='introduccion_editor' or 
                            $etiquetaParatexto ='introduccion_editor_digital' or 
                            $etiquetaParatexto ='introduccion_autor' or 
                            $etiquetaParatexto ='introduccion_traductor' or 
                            $etiquetaParatexto ='licencia' or 
                            $etiquetaParatexto ='nota_edicion_digital' or 
                            $etiquetaParatexto ='aparato_critico' or 
                            $etiquetaParatexto ='bibliografia')">
                        <xsl:variable name="cabecera">
                            <xsl:value-of select="tei:head"/>
                        </xsl:variable>
                        <div id="{$etiquetaParatexto}" class="paratextos">
                            <a name="{$etiquetaParatexto}"></a>
                            <p class="cabecera">
                                <xsl:if test="$cabecera!=''">
                                    <xsl:value-of select="$cabecera"/>
                                </xsl:if>
                                <xsl:if test="$cabecera=''">
                                    <!--<xsl:value-of select="$labels/*[local-name() = $etiquetaParatexto][@lang=$pLang]"/>-->
                                </xsl:if>
                            </p>
                            <xsl:for-each select="./*">
                                <xsl:if test="name()!='head'">
                                    <xsl:apply-templates select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </div>
                    </xsl:when>

                    <xsl:when test="@type = 'elenco'">
                        <div id="elenco">
                            <xsl:variable name="cabecera">
                                <xsl:value-of select="tei:head"/>
                            </xsl:variable>
                            <p class="posicion_ancla">
                                <a name="elenco"></a>
                            </p>
                            <p class="cabecera">
                                <!--<xsl:if test="$cabecera=''">
                                    <xsl:text><xsl:value-of select="$labels/elenco[@lang = $pLang]"/></xsl:text>
                                </xsl:if>-->
                                <xsl:if test="$cabecera!=''">
                                    <xsl:value-of select="$cabecera"/>
                                </xsl:if>
                            </p>

                            <p class="intro">
                                <xsl:value-of select="tei:p"/>
                            </p>
                            <div class="center">
                                <table>
                                    <xsl:for-each select="tei:castList/tei:castItem">
                                        <xsl:variable name="ana">
                                            <xsl:value-of select="@ana"/>
                                        </xsl:variable>
                                        <xsl:variable name="nombre">
                                            <xsl:value-of select="tei:role"/>
                                        </xsl:variable>
                                        <xsl:variable name="descripcion">
                                            <xsl:value-of select="tei:roleDesc"/>
                                        </xsl:variable>

                                        <xsl:if test="not(contains($ana, 'oculto'))">
                                            <tr>
                                                <td>
                                                    <xsl:if test="$descripcion=''">
                                                        <xsl:value-of select="tei:role" />
                                                    </xsl:if>
                                                    <xsl:if test="$descripcion!=''">
                                                        <xsl:value-of select="tei:role" />
                                                        <xsl:text>, </xsl:text>
                                                        <xsl:value-of select="tei:roleDesc" />
                                                    </xsl:if>
                                                </td>
                                            </tr>
                                        </xsl:if>
                                    </xsl:for-each>
                                </table>
                            </div>
                            <xsl:for-each select="tei:note/tei:p">
                                <!--<p class="nota">-->
                                <p>
                                    <!--<xsl:value-of select="." />-->
                                    <xsl:apply-templates />
                                </p>
                            </xsl:for-each>
                        </div>
                    </xsl:when>

                    <xsl:when test="@type = 'loa'">
                        <xsl:variable name="cabecera">
                            <xsl:value-of select="tei:head"/>
                        </xsl:variable>
                        <div id="elenco" class="paratextos">
                            <a name="{@type}"></a>
                            <p class="cabecera">
                                <xsl:if test="$cabecera=''">
                                    <xsl:value-of select="$labels/loa[@lang=$pLang]"/>
                                </xsl:if>
                                <xsl:if test="$cabecera!=''">
                                    <xsl:value-of select="$cabecera"/>
                                </xsl:if>
                            </p>
                            <p class="cabecera">
                                <xsl:value-of select="tei:head[2]"/>
                            </p>
                            <div class="center">
                                <table>
                                    <xsl:for-each select="tei:castList/tei:castItem">
                                        <xsl:variable name="ana">
                                            <xsl:value-of select="@ana"/>
                                        </xsl:variable>
                                        <xsl:variable name="nombre">
                                            <xsl:value-of select="tei:role"/>
                                        </xsl:variable>
                                        <xsl:variable name="descripcion">
                                            <xsl:value-of select="tei:roleDesc"/>
                                        </xsl:variable>
                                        <!--<xsl:if test="not(starts-with($nombre,'*'))">-->
                                        <xsl:if test="not(contains($ana, 'oculto'))">
                                            <tr>
                                                <td>
                                                    <xsl:if test="$descripcion=''">
                                                        <xsl:value-of select="tei:role" />
                                                    </xsl:if>
                                                    <xsl:if test="$descripcion!=''">
                                                        <xsl:value-of select="tei:role" />
                                                        <xsl:text>, </xsl:text>
                                                        <xsl:value-of select="tei:roleDesc" />
                                                    </xsl:if>
                                                </td>
                                            </tr>
                                        </xsl:if>
                                    </xsl:for-each>
                                </table>
                            </div>
                            <xsl:for-each select="./*">
                                <xsl:if test="name()!='head' and name()!='castList'">
                                    <xsl:apply-templates select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </div>
                    </xsl:when>

                    <xsl:otherwise>
                        <div id="otroTipo" class="paratextos">
                            <p>Otro tipo (por añadir)</p>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>

                <hr class="sigilChapterBreak"/>
            </xsl:for-each>

            <xsl:for-each select="tei:set">
                <xsl:variable name="cabecera">
                    <xsl:value-of select="tei:head"/>
                </xsl:variable>
                <div id="argumento" class="paratextos">
                    <a name="lugar_accion"></a>
                    <!--<p class="cabecera">
                        <xsl:text>Setting of the action</xsl:text>
                    </p>-->
                    <xsl:for-each select="./*">
                        <xsl:if test="name()!='head'">
                            <xsl:apply-templates select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </div>
                <hr class="sigilChapterBreak"/>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template match="tei:bibl/tei:note">
        <xsl:apply-templates/>
    </xsl:template>
    <!--....................................................................-->

    <!--.......................PARATEXTOS POSTERIORES.......................-->
    <!-- Recorremos los paratextos posteriores -->
    <xsl:template match="tei:back">
        <div id="back">
            <xsl:for-each select="tei:div">
                <xsl:variable name="etiquetaParatextoBack">
                    <xsl:value-of select="@type"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="($etiquetaParatextoBack = 'colofon' or 
                        $etiquetaParatextoBack ='despedida' or 
                        $etiquetaParatextoBack ='licencia' or 
                        $etiquetaParatextoBack ='sarao' or 
                        $etiquetaParatextoBack ='apendice' or 
                        $etiquetaParatextoBack ='nota_edicion_digital' or
                        $etiquetaParatextoBack ='aparato_critico' or
                        $etiquetaParatextoBack ='epilogo' or 
                        $etiquetaParatextoBack ='bibliografia')">
                        <xsl:variable name="cabecera">
                            <xsl:value-of select="tei:head"/>
                        </xsl:variable>
                        <div id="{$etiquetaParatextoBack}" class="paratextos">
                            <a name="{$etiquetaParatextoBack}"></a>
                            <p class="cabecera">
                                <xsl:if test="$cabecera=''">
                                    <xsl:value-of select="$labels/*[local-name() = $etiquetaParatextoBack][@lang=$pLang]"/>
                                </xsl:if>
                                <xsl:if test="$cabecera!=''">
                                    <xsl:value-of select="$cabecera"/>
                                </xsl:if>
                            </p>
                            <xsl:for-each select="./*">
                                <xsl:if test="name()!='head'">
                                    <xsl:apply-templates select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </div>

                    </xsl:when>

                    <xsl:otherwise>
                        <div id="otroTipo">
                            <p>Otro tipo (por añadir)</p>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <hr class="sigilChapterBreak"/>
            </xsl:for-each>
        </div>
    </xsl:template>
    <!--....................................................................-->

    <!--.............................ACTOS..................................-->
    <!-- Recorremos los actos -->
    <xsl:template match="tei:body">
        <div id="body">
            <xsl:for-each select="tei:div1">
                <xsl:variable name="tipoSeccion">
                    <xsl:value-of select="@type"/>
                </xsl:variable>
                <div class="div1">
                    <xsl:variable name="etiquetaActo">
                        <xsl:value-of select="$tipoSeccion"/>
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="@n"/>
                    </xsl:variable>

                    <!-- Enlace acto -->
                    <xsl:if test="$etiquetaActo!=''">
                        <p>
                            <a name="{$etiquetaActo}"></a>
                        </p>
                    </xsl:if>
                    <xsl:if test="$etiquetaActo=''">
                        <p>
                            <a name="texto"></a>
                        </p>
                    </xsl:if>
                    <xsl:apply-templates/>
                </div>
                <hr class="sigilChapterBreak"/>
            </xsl:for-each>
        </div>
    </xsl:template>
    <!--....................................................................-->

    <!--..........................TÍTULO ACTO...............................-->
    <xsl:template match="tei:div1/tei:head">
        <h2 class="tituloActo">
            <xsl:value-of select="concat(translate(substring(., 1, 1), $lowercase, $uppercase), substring(., 2))"/>
        </h2>
    </xsl:template>
    <!--....................................................................-->

    <!--..........................TÍTULO ESCENA.............................-->
    <xsl:template match="tei:div2/tei:head">
        <h3 class="tituloEscena">
            <span class="numVersoInterno" name="numVerso">
                <xsl:value-of select="../@n"/>
            </span>
            <xsl:apply-templates />
        </h3>
    </xsl:template>
    <!--....................................................................-->

    <!--..........................ELENCO....................................-->
    <xsl:template match="tei:div1//tei:castList">
        <p>
            <div align="center">
                <table>
                    <xsl:for-each select="tei:castItem">
                        <tr>
                            <td>
                                <xsl:value-of select="tei:role"/>
                                <xsl:if test="tei:roleDesc!=''">
                                    <xsl:text>, </xsl:text>
                                    <xsl:value-of select="tei:roleDesc"/>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </div>
        </p>
    </xsl:template>
    <!--....................................................................-->


    <!--.......................... ESCENA.............................-->
    <xsl:template match="tei:div2">
        <div class="div2">
            <xsl:apply-templates />
        </div>
    </xsl:template>
    <!--..............................................................-->

    <!--..........................PÁRRAFO.............................-->
    <xsl:template match="tei:div/tei:p | tei:note/tei:p">
        <p>
            <xsl:apply-templates />
        </p>
    </xsl:template>
    <!--..............................................................-->

    <!--.....................LINE BREAK...............................-->
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    <!--..............................................................-->

    <!--.......................... ACOTACIÓN EXTERNA........................-->
    <xsl:template match="tei:div1/tei:stage | tei:div2/tei:stage | tei:sp/tei:stage">
        <div class="acotacionExterna" name="acotacionExterna">
            <span class="numVersoInterno" name="numVerso">
                <xsl:value-of select="@n"/>
            </span>
            <xsl:apply-templates />
        </div>
    </xsl:template>
    <!--....................................................................-->

    <!--.......................... ACOTACIÓN INTERNA........................-->
    <xsl:template match="tei:lg/tei:stage">
        <div class="acotacionInterna" name="acotacionInterna">
            <!--<xsl:value-of select="." disable-output-escaping="yes"/>-->
            <span class="numVersoInterno" name="numVerso">
                <xsl:value-of select="@n"/>
            </span>
            <xsl:apply-templates />
        </div>
        <xsl:text></xsl:text>
    </xsl:template>
    <!--....................................................................-->

    <!--...........................DELIVERY.................................-->
    <xsl:template match="tei:l/tei:stage">
        <xsl:choose>
            <xsl:when test="@type = 'delivery'">
                <div class="etiquetaAparte" name="etiquetaAparte">
                    <!--<xsl:value-of select="."/>-->
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="acotacionInterna" name="acotacionInterna">
                    <!--<xsl:value-of select="."/>-->
                    <xsl:apply-templates />
                </div>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:p/tei:stage">
        <xsl:choose>
            <xsl:when test="@type = 'delivery'">
                <span class="etiquetaAparteProsa" name="etiquetaAparteProsa">
                    <xsl:apply-templates />
                </span>
                <xsl:text></xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <span class="acotacionInterna" name="acotacionInterna">
                    <xsl:apply-templates />
                </span>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--....................................................................-->

    <!--............................SPEECH..................................-->
    <xsl:template match="tei:sp">
        <div class="parlamento">
            <p>
                <xsl:apply-templates />
            </p>
        </div>
    </xsl:template>
    <!--....................................................................-->

    <!--............................SPEAKER.................................-->
    <xsl:template match="tei:speaker">
        <div class="speaker">
            <!--<xsl:value-of select="."/>-->
            <!--<xsl:value-of select="." disable-output-escaping="yes"/>-->
            <xsl:apply-templates />
        </div>
    </xsl:template>
    <!--....................................................................-->

    <!--............................LINE GROUP..............................-->
    <xsl:template match="tei:lg">
        <xsl:variable name="tipoEstrofa">
            <xsl:value-of select="@type"/>
        </xsl:variable>
        <xsl:variable name="nombreEstrofa">
            <xsl:value-of select="$metrica/*[local-name() = $tipoEstrofa]"/>
-->     </xsl:variable>
        <xsl:variable name="parteEstrofa">
            <xsl:value-of select="@part"/>
        </xsl:variable>
        <xsl:variable name="particionEstrofa">
            <xsl:choose>
                <xsl:when test="@part">
                    <xsl:value-of select="@part" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'IMF'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="$tipoEstrofa=''">
            <div>
                <xsl:apply-templates />
            </div>
        </xsl:if>
        <xsl:if test="$tipoEstrofa!=''">
            <xsl:if test="$parteEstrofa!='M' and $parteEstrofa!='F'">
                <div>
                    <xsl:attribute name="class">
                        <xsl:text>etiqueta_metrica</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="name">
                        <xsl:value-of select="$tipoEstrofa"/>
                    </xsl:attribute>
                    <xsl:value-of select="$nombreEstrofa"/>
                </div>
            </xsl:if>
            <div>
                <xsl:attribute name="class">
                    <xsl:text>lg_</xsl:text>
                    <xsl:value-of select="$tipoEstrofa"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="$particionEstrofa"/>
                </xsl:attribute>
                <xsl:attribute name="name">
                    <xsl:text>lg_</xsl:text>
                    <xsl:value-of select="$tipoEstrofa"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="$particionEstrofa"/>
                </xsl:attribute>
                <xsl:apply-templates />
            </div>
        </xsl:if>
    </xsl:template>
    <!--....................................................................-->


    <xsl:template match="tei:l/tei:seg">
        <xsl:variable name="segmento">
            <xsl:value-of select="@xml:id"/>
        </xsl:variable>
        <xsl:if test="contains($segmento,'seg01') or $segmento=''">
            <span class="aparte" name="aparteI">
                <!--<xsl:value-of select="."/>-->
                <xsl:apply-templates/>
            </span>
        </xsl:if>
        <xsl:if test="not(contains($segmento,'seg01') or $segmento='')">
            <span class="aparte" name="aparte">
                <!--<xsl:value-of select="."/>-->
                <xsl:apply-templates/>
            </span>
        </xsl:if>

    </xsl:template>

    <xsl:template match="tei:head/tei:app | tei:stage/tei:app | tei:speaker/tei:app | tei:p/tei:app | tei:l/tei:app | tei:seg/tei:app | //tei:trailer/tei:app">
        <xsl:variable name="num">
            <xsl:value-of select="@n"/>
        </xsl:variable>
        <span class="iconoVariante" onclick="mostrarVariante({$num})">
            <xsl:attribute name="id">
                <xsl:value-of select="$num"/>
            </xsl:attribute>
            <xsl:text>*</xsl:text>
        </span>
        <div class="contenidoVariante">
            <xsl:attribute name="id">
                <xsl:text>cv-</xsl:text>
                <xsl:value-of select="$num"/>
            </xsl:attribute>
            <div class="cerrarVariante" onclick="cerrarVariante({$num})">X</div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:app/tei:lem | tei:app/tei:rdg">
        <xsl:text>- </xsl:text>
        <em>
            <xsl:value-of select="replace(@wit,'#','')"/>
        </em>
        <xsl:text></xsl:text>
        <xsl:apply-templates/>
        <br/>
    </xsl:template>

    <xsl:template match="tei:lem/tei:note | tei:rdg/tei:note">
        <xsl:text></xsl:text>
        <em>(            <xsl:value-of select="."/>
)</em>
    </xsl:template>

    <xsl:template match="tei:app/tei:note">
        <!--<b><xsl:text>Nota:</xsl:text></b><br/>-->
        <xsl:apply-templates/>
    </xsl:template>

    <!--................................NOTA...............................-->
    <!--    <xsl:template match="">
        <xsl:text>pewla</xsl:text>
    </xsl:template>-->

    <xsl:template match="tei:seg/tei:note | tei:l/tei:note | tei:p/tei:note | tei:stage/tei:note | tei:speaker/tei:note | tei:head/tei:note | //tei:trailer//tei:note">
        <!--<div class="nota">
            <xsl:value-of select="."/>
        </div>-->
        <xsl:variable name="tipoNota">
            <xsl:value-of select="@type"/>
        </xsl:variable>
        <xsl:if test="$tipoNota='editor_digital' 
            or $tipoNota='traductor' 
            or $tipoNota='autor'
            or $tipoNota='editor'">
            <xsl:variable name="num">
                <xsl:value-of select="@n"/>
            </xsl:variable>
            <xsl:variable name="tipo">
                <xsl:value-of select="@type"/>
            </xsl:variable>
            <xsl:variable name="cabeceraNota">
                <xsl:choose>
                    <!--<xsl:when test="matches($tipo,'editor_digital | editor')">-->
                    <xsl:when test="($tipo = 'editor_digital' or $tipo='editor')">
                        <xsl:value-of select="$labels/nota_editor[@lang = $pLang]"/>
                    </xsl:when>
                    <xsl:when test="$tipo='traductor'">
                        <xsl:value-of select="$labels/nota_traductor[@lang = $pLang]"/>
                    </xsl:when>
                    <xsl:when test="$tipo='autor'">
                        <xsl:value-of select="$labels/nota_autor[@lang = $pLang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Definir_tipo</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <span class="iconoNota" onclick="mostrarNota({$num})">
                <xsl:attribute name="id">
                    <xsl:value-of select="$num"/>
                </xsl:attribute>
                <xsl:text>N</xsl:text>
            </span>
            <span class="contenidoNota">
                <xsl:attribute name="id">
                    <xsl:text>cn-</xsl:text>
                    <xsl:value-of select="$num"/>
                </xsl:attribute>
                <span class="cerrarNota" onclick="cerrarNota({$num})">X</span>
                <strong>
                    <xsl:value-of select="$cabeceraNota"/>
                </strong>
                <br/>
                <xsl:apply-templates/>
            </span>
        </xsl:if>
    </xsl:template>
    <!--.......................................................................-->

    <!--................................RESOURCE...............................-->
    <xsl:template match="tei:rs">
        <xsl:apply-templates/>
    </xsl:template>
    <!--.......................................................................-->

    <!--................................TERM,,,,...............................-->
    <xsl:template match="tei:note/tei:term">
        <!--nothing-->
    </xsl:template>
    <!--.......................................................................-->




    <!--................................LINEA...............................-->
    <xsl:template match="tei:l">
        <!--<xsl:variable name="numVerso"><xsl:value-of select="number(@n)"/></xsl:variable>
        <xsl:if test="$numVerso mod 5=0 and $numVerso!=0">
            <div class="numVerso" name="numVerso"><xsl:value-of select="$numVerso"/></div>
        </xsl:if>-->
        <div class="numVerso" name="numVerso">
            <xsl:value-of select="@n"/>
        </div>
        <xsl:variable name="tipoVerso">
            <xsl:value-of select="@part"/>
        </xsl:variable>
        <xsl:variable name="sangrado">
            <xsl:value-of select="@rend"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$sangrado='indent' and $tipoVerso='I'">
                <div class="versoI versoSangrado" name="versoI">
                    <xsl:apply-templates />
                </div>
            </xsl:when>
            <xsl:when test="$sangrado='indent'">
                <div class="versoSangrado" name="versoSangrado">
                    <xsl:apply-templates />
                </div>
            </xsl:when>
            <xsl:when test="$tipoVerso='I' and (position()+1)=last()">
                <div class="versoI" name="versoI">
                    <xsl:apply-templates />
                </div>
            </xsl:when>
            <xsl:when test="$tipoVerso='M'">
                <xsl:if test="position()=2">
                    <div class="versoM" name="versoM">
                        <xsl:apply-templates />
                    </div>
                </xsl:if>
                <xsl:if test="position()!=2">
                    <div class="versoM2" name="versoM2">
                        <xsl:apply-templates />
                    </div>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$tipoVerso='F'">
                <xsl:if test="position()=2">
                    <div class="versoF" name="versoF">
                        <xsl:apply-templates />
                    </div>
                </xsl:if>
                <xsl:if test="position()!=2">
                    <div class="versoF2" name="versoF2">
                        <xsl:apply-templates />
                    </div>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <div class="verso" name="verso">
                    <xsl:apply-templates />
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--....................................................................-->

    <!--.........................PROSA APARTE...............................-->
    <xsl:template match="tei:p/tei:seg">
        <span class="aparte" name="aparteI">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <!--....................................................................-->

    <!--...........................PROSA....................................-->
    <xsl:template match="tei:p">
        <div class="prosa">
            <span class="numVersoInterno" name="numVerso">
                <xsl:value-of select="@n"/>
            </span>
            <xsl:apply-templates />
        </div>
    </xsl:template>
    <!--....................................................................-->

    <!--...........................TRAILER..................................-->
    <xsl:template match="tei:trailer">
        <div class="final" name="final">
            <xsl:apply-templates />
            <!--<xsl:value-of select="."/>--></div>
    </xsl:template>
    <!--....................................................................-->

    <!--............................EMPH....................................-->
    <xsl:template match="tei:emph">
        <i>
            <xsl:value-of select="."/>
        </i>
    </xsl:template>
    <!--....................................................................-->

    <xsl:template match="tei:sp/tei:p/tei:lb">
        <!--<br/>-->
        <span class="numVersoInterno" name="numVerso">
            <xsl:value-of select="@n"/>
        </span>
        <xsl:apply-templates/>
    </xsl:template>
    <!--....................................................................-->

    <!--............................CODE....................................-->
    <xsl:template match="tei:code">
        <xsl:value-of select="." disable-output-escaping="yes"/>
    </xsl:template>
    <!--....................................................................-->

</xsl:stylesheet>