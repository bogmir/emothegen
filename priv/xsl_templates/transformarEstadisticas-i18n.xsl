<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output indent="yes"/>
        
    <xsl:variable name="labels" select="document('Emothe_labels.xml')/labels"/>
    <xsl:variable name="particion"><xsl:value-of select="estadisticasObra/estructura/@tipo"/></xsl:variable>
    <xsl:variable name="tipoLinea"><xsl:value-of select="estadisticasObra/lineas/@tipo"/></xsl:variable>
    <xsl:variable name="nombreFichero"><xsl:value-of select="estadisticasObra/tituloArchivo"/></xsl:variable>
    <xsl:variable name="idioma" select="estadisticasObra/idioma"/>
    <xsl:variable name="tipoSecciones">
        <xsl:for-each select="/estadisticasObra/estructura/tipoSecciones/tipoSeccion">
                <xsl:value-of select="."/>                  
        </xsl:for-each>     
    </xsl:variable> 
    
    <xsl:param name="pLang" select="substring($idioma,1,2)"/>
    
    <xsl:template match="estadisticasObra">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <meta http-equiv="X-UA-compatible" content="IE=8"/>
                <meta http-equiv="Content-Language" content="es"/>
                <title>
                    <xsl:value-of select="tituloObra"/>
                    
                    <!-- - STATISTICS-->
                    <xsl:text> - </xsl:text><xsl:value-of select="$labels/estadisticas[@lang = $pLang]"/>
                </title>
                <xsl:variable name="prefijo">
                    <xsl:if test="substring($nombreFichero,1,2)='C6'">
                        <xsl:text></xsl:text>
                    </xsl:if>
                    <xsl:if test="not(substring($nombreFichero,1,2)='C6')">
                        <xsl:text>../</xsl:text>
                    </xsl:if>
                </xsl:variable>
                <xsl:element name="script">
                    <xsl:attribute name="type">
                        <xsl:text>text/javascript</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="src">
                        <xsl:value-of select="$prefijo"/>
                        <xsl:text>../js/jquery.js</xsl:text>
                    </xsl:attribute>
                </xsl:element>
                <xsl:element name="script">
                    <xsl:attribute name="src">
                        <xsl:value-of select="$prefijo"/>
                        <xsl:text>../js/SpryAssets/SpryAccordion.js</xsl:text>
                    </xsl:attribute>
                </xsl:element>
                <xsl:if test="substring($nombreFichero,1,2)='C6'">
                    <link href="../js/SpryAssets/SpryAccordion.css" rel="stylesheet" type="text/css"/>
                    <link href="../css/estadisticas.css" rel="stylesheet" type="text/css"/>
                </xsl:if>
                <xsl:if test="not(substring($nombreFichero,1,2)='C6')">
                    <link href="../../js/SpryAssets/SpryAccordion.css" rel="stylesheet" type="text/css"/>
                    <link href="../../css/estadisticas.css" rel="stylesheet" type="text/css"/>
                </xsl:if>
            </head>
            <body>
                <div id="Accordion1" class="Accordion" tabindex="0">
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab"><xsl:value-of select="$labels/estructura_obra[@lang = $pLang]"/></div>
                        <div class="AccordionPanelContent">
                            <xsl:apply-templates select="estructura" />
                            <xsl:apply-templates select="lineas" />
                            <xsl:apply-templates select="acotaciones" />
                            <xsl:if test="not(substring($nombreFichero,1,2)='C6')">
                                <xsl:apply-templates select="apartes" />
                            </xsl:if>
                        </div>
                    </div>
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab"><xsl:value-of select="$labels/intervenciones_personajes[@lang = $pLang]"/></div>
                        <div class="AccordionPanelContent">
                            <ul class="pauta">
                                <li><xsl:value-of select="$labels/nota_nombres_ast[@lang = $pLang]"/></li>
                                <li><xsl:value-of select="$labels/nota_cifra_mas[@lang = $pLang]"/></li>
                            </ul>
                            
                            <xsl:for-each select="intervenciones">
                                <xsl:apply-templates select="." />
                            </xsl:for-each>
                        </div>
                    </div>
                    
                    <xsl:if test="$tipoLinea='verso' and not (substring($nombreFichero,1,2)='C6')">
                        <div class="AccordionPanel">
                            <div class="AccordionPanelTab"><xsl:value-of select="$labels/metrica[@lang = $pLang]"/></div>
                            <div class="AccordionPanelContent">
                                <xsl:apply-templates select="estrofas"/>
                                <xsl:apply-templates select="estudioMetrica"/>
                            </div>
                        </div>
                    </xsl:if>
                </div>
                <script type="text/javascript">var Acc1 = new Spry.Widget.Accordion("Accordion1", { useFixedPanelHeights: false });</script> 
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="estructura">
        <table>
            <tr id="resaltado">
                <td class="first">
                    <xsl:value-of select="$labels/no_secciones[@lang = $pLang]"/>
                </td>
                <td class="right"><xsl:value-of select="totalEstructura"/></td>
            </tr>
            <xsl:apply-templates select="escenas"/>
        </table>
    </xsl:template>
    
    <xsl:template match="escenas">
        <tr>
            <td><xsl:value-of select="$labels/escenas[@lang = $pLang]"/></td>
            <td class="right"><xsl:value-of select="totalEscenas"/></td>
        </tr>
        
        <xsl:for-each select="escenasActo">
            <xsl:variable name="index" select="@n"/>
            <tr>
                <td class="pleft">
                    <xsl:value-of select="/estadisticasObra/estructura/tipoSecciones/tipoSeccion[number($index)]"/>
                </td>
                <td class="right"><xsl:value-of select="."/></td>
            </tr>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="lineas">
        <table>
            <tr id="resaltado">
                <xsl:if test="@tipo='verso'">
                    <td class="first"><xsl:value-of select="$labels/total_versos[@lang = $pLang]"/></td>
                </xsl:if>
                <xsl:if test="@tipo='prosa'">
                    <td class="first"><xsl:value-of select="$labels/total_parrafos[@lang = $pLang]"/></td>
                </xsl:if>
                <td class="right"><xsl:value-of select="totalLineas"/></td>
            </tr>
            <tr>
                <td><xsl:value-of select="$labels/distribucion[@lang = $pLang]"/></td>
                <td></td>
            </tr>
            <xsl:for-each select="lineasActo">
                <xsl:variable name="index" select="@n"/>
                <tr>
                      <td class="pleft"><xsl:value-of select="/estadisticasObra/estructura/tipoSecciones/tipoSeccion[number($index)]"/></td>
                      <td class="right"><xsl:value-of select="."/></td>
                </tr>
            </xsl:for-each>
        </table>
        
        <xsl:if test="$tipoLinea='verso'">
            <table>
                <tr><td><xsl:value-of select="$labels/versos_partidos[@lang = $pLang]"/></td>
                    <td class="right"><xsl:value-of select="versosTruncados"/></td>
                </tr>
            </table>
        </xsl:if>
        
        <xsl:if test="$tipoLinea='verso'">
            <table>
                <xsl:variable name="fProsa"><xsl:value-of select="fragmentosProsa"/></xsl:variable>
                <tr id="resaltado">
                    <td class="first"><xsl:value-of select="$labels/fragmentos_prosa[@lang = $pLang]"/></td><td class="right"><xsl:value-of select="$fProsa"/></td></tr>
                <xsl:if test="$fProsa > 0">
                    <xsl:for-each select="fragmentosProsaActo">
                        <xsl:variable name="index" select="@n"/>
                        <tr>
                            <td class="pleft">
                                <xsl:value-of select="/estadisticasObra/estructura/tipoSecciones/tipoSeccion[number($index)]"/>
                            </td>
                            <td class="right"><xsl:value-of select="."/></td>
                        </tr>
                    </xsl:for-each>
                </xsl:if>
            </table>
        </xsl:if>
        
        <xsl:if test="$tipoLinea='prosa'">
            <table>
                <xsl:variable name="fVerso"><xsl:value-of select="fragmentosVerso"/></xsl:variable>
                <tr id="resaltado">
                    <td class="first"><xsl:value-of select="$labels/versos[@lang = $pLang]"/></td><td class="right"><xsl:value-of select="$fVerso"/></td></tr>
                <xsl:if test="$fVerso>0">
                   <xsl:for-each select="fragmentosVersoActo">
                       <xsl:variable name="index" select="@n"/>
                       <tr>
                           <td class="pleft"><xsl:value-of select="$tipoSecciones[number($index)]"/></td>
                           <td class="right"><xsl:value-of select="."/></td>
                       </tr>
                   </xsl:for-each>
                </xsl:if>
            </table>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="acotaciones">
        <table>
            <tr id="resaltado">
                <td class="first"><xsl:value-of select="$labels/total_acotaciones[@lang = $pLang]"/></td>
                <td class="right"><xsl:value-of select="totalAcotaciones"/></td>
            </tr>
            <!--<xsl:apply-templates select="acotacionesExternas"></xsl:apply-templates>
            <xsl:apply-templates select="acotacionesInternas"></xsl:apply-templates>-->
        </table>
    </xsl:template>
    
    <xsl:template match="acotacionesExternas">
        <tr>
            <td class="pleft"><xsl:value-of select="$labels/acotaciones_externas[@lang = $pLang]"/></td>
            <td class="right"><xsl:value-of select="."/></td>
        </tr>
    </xsl:template>
    
    <xsl:template match="acotacionesInternas">
        <tr>
            <td class="pleft"><xsl:value-of select="$labels/acotaciones_internas[@lang = $pLang]"/></td>
            <td class="right"><xsl:value-of select="."/></td>
        </tr>
    </xsl:template>
    
    <xsl:template match="apartes">
        
        <table>
            <tr id="resaltado">
                <td class="first"><xsl:value-of select="$labels/total_apartes[@lang = $pLang]"/></td>
                <td class="right"><xsl:value-of select="totalApartes"/></td>
            </tr>
            <xsl:if test="totalApartes &gt; 0">
                <xsl:if test="$tipoLinea='verso'">
                    <tr>
                        <td class="pleft"><xsl:value-of select="$labels/versos_aparte[@lang = $pLang]"/> </td>
                        <td class="right"><xsl:value-of select="versosAparte"/></td></tr>
                </xsl:if>
                <tr>
                    <td class="pleft"><xsl:value-of select="$labels/etiquetas_aparte[@lang = $pLang]"/> <xsl:value-of select="@n"/></td>
                    <td class="right"><xsl:value-of select="etiquetasAparte"/></td>
                </tr>
            </xsl:if>
        </table>
    </xsl:template>
    
    
    <xsl:template match="intervenciones">
        <table>
            <xsl:if test="@tipo='unica'">
                <tr>
                    <th class="first"><xsl:value-of select="$labels/personajes[@lang = $pLang]"/></th>
                    <xsl:if test="$tipoLinea='verso'">
                        <th colspan="2"><xsl:value-of select="$labels/versos_completos[@lang = $pLang]"/></th>
                        <th colspan="2"><xsl:value-of select="$labels/versos_partidos[@lang = $pLang]"/></th>
                    </xsl:if>
                    <th colspan="2"><xsl:value-of select="$labels/intervenciones[@lang = $pLang]"/></th>
                </tr>
                <xsl:for-each select="intervencion">
                    <xsl:sort select="numVersos" data-type="number" order="descending"/>
                    <tr>
                        <td class="left"><xsl:value-of select="personaje"/></td>
                        <xsl:if test="$tipoLinea='verso'">
                            <td class="right">
                                <xsl:value-of select="numVersos"/>
                            </td>
                            <td class="conjunto">
                                <xsl:if test="numVersosConjunto > 0">
                                    <xsl:text> +</xsl:text><xsl:value-of select="numVersosConjunto"/>
                                </xsl:if>
                            </td>
                            <td class="right">
                                <xsl:value-of select="numVersosPartidos"/>
                            </td>
                            <td class="conjunto">
                                <xsl:if test="numVersosPartidosConjunto > 0">
                                    <xsl:text> +</xsl:text><xsl:value-of select="numVersosPartidosConjunto"/>
                                </xsl:if>
                            </td>
                        </xsl:if>
                        <td class="right">
                            <xsl:value-of select="numIntervenciones"/>
                        </td>
                        <td class="conjunto">
                            <xsl:if test="numIntervencionesConjunto > 0">
                                <xsl:text> +</xsl:text><xsl:value-of select="numIntervencionesConjunto"/>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="@tipo!='unica'">
                <tr>
                    <th class="first"><xsl:value-of select="$labels/agrupaciones[@lang = $pLang]"/></th>
                   <xsl:if test="$tipoLinea='verso'">
                       <th><xsl:value-of select="$labels/versos_completos[@lang = $pLang]"/></th>
                       <th><xsl:value-of select="$labels/versos_partidos[@lang = $pLang]"/></th>
                   </xsl:if>
                    <th><xsl:value-of select="$labels/intervenciones[@lang = $pLang]"/></th>
                </tr>
                <xsl:for-each select="intervencion">
                    <xsl:sort select="numVersos" data-type="number" order="descending"/>
                    <tr>
                        <td class="left"><xsl:value-of select="personaje"/></td>
                        <xsl:if test="$tipoLinea='verso'">
                            <td class="right">
                                <xsl:value-of select="numVersos"/>
                            </td>
                            <td class="right">
                                <xsl:value-of select="numVersosPartidos"/>
                            </td>
                        </xsl:if>
                        <td class="right">
                            <xsl:value-of select="numIntervenciones"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>
            
            
        </table>
       
    </xsl:template>
    
    <xsl:template match="estrofas">
        <table>
            <tr>
                <th class="first"><xsl:value-of select="$labels/estrofas[@lang = $pLang]"/></th>
                <th><xsl:value-of select="$labels/versos[@lang = $pLang]"/></th>
                <th><xsl:value-of select="$labels/no_estrofas[@lang = $pLang]"/></th>
            </tr>
            <xsl:for-each select="estrofa">
                <xsl:sort select="numVersos" data-type="number" order="descending"/>
                <tr>
                    <td><xsl:value-of select="nombreEstrofa"/></td>
                    <td class="right"><xsl:value-of select="numVersos"/></td>
                    <td class="right"><xsl:value-of select="numEstrofas"/></td>
                </tr>
            </xsl:for-each>
        </table>
        <hr/>
    </xsl:template>
    
    <xsl:template match="estudioMetrica">
        <div id="resaltado"><xsl:value-of select="$labels/estudio_metrica[@lang = $pLang]"/></div>
        <table>
            <tr>
                <th class="first"><xsl:value-of select="$labels/estrofas[@lang = $pLang]"/></th>
                <th><xsl:value-of select="$labels/rango_versos[@lang = $pLang]"/></th>
            </tr>
            <xsl:for-each select="lineaEstudioMetrica">
                <tr>
                    <td><xsl:value-of select="tipoEstrofa"/></td>
                    <td class="right"><xsl:value-of select="rango"/></td>
                </tr>
            </xsl:for-each>    
        </table>  
    </xsl:template>
</xsl:stylesheet>