### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 1e264b46-fd83-4ee0-952a-544d38a7ac76
using PlutoUI, Plots, Distributions, DataFrames

# ╔═╡ aacc06b4-1afb-4e83-8392-45b2e24eb51a
md"# _Distribuciones_


En este notebook exploraremos distribuciones, podrás explorar entre la **teoria,  casos de aplicacion y ejercicios**.  Para hacerlo mas interesante, descubriras que esta diseñado para ser **interactivo** y lo mas intuitivo posible. Disfrutalo ✨

Por Alexia Berenice Torres Calderon"

# ╔═╡ d0ae819a-d96a-4715-86f0-e6e480d0714b
begin
	function plot_cumulative!(ps, δ=1; label="")
	    
	    cumulative = cumsum(ps)
		
	
	    ys = [0; reduce(vcat, [ [cumulative[n], cumulative[n]] for n in 1:length(ps) ])]
	  
	    pop!(ys)
	    pushfirst!(ys,0)
		push!(ys,1)
	
	    xs = [-1; reduce(vcat, [ [n*δ, n*δ] for n in 0:length(ps)-1])];
		push!(xs,length(ps))
	
	    plot!(xs, ys, label=label, color=:black)
	
	    scatter!([n*δ for n in 0:length(ps)-1], cumulative, label="")
	end
	
	function TeoricBarplot( distribution, xmin, n_x_values, ylim=1;auto=false, geo=0)
		
		xvalues=[i for i in xmin:(xmin+n_x_values-1)]
		probs=[pdf(distribution, i) for i in xmin-geo:(xmin+n_x_values-1)-geo]
		
		if auto ==true 
		plot((xvalues, probs),seriestype =:bar, leg=false, 
	        ylabel="Probabilidad", xlabel="Valores de v.a X", xticks=xvalues, alpha = 0.5)
		
		else 
			plot((xvalues, probs),seriestype =:bar, leg=false, 
	        ylabel="Probabilidad", xlabel="Valores de v.a X", xticks=xvalues, ylims=(0,ylim+0.1), alpha = 0.5)
		end
		
	end
	
	RandomBinomial(p,N)=sum([rand()<p for i in 1:N]);
	

function plot_cumulative2!(ps, δ=1; label="")
	    
	    cumulative = cumsum(ps)

    ys = [0; reduce(vcat, [ [cumulative[n], cumulative[n]] for n in 1:length(ps) ])]

    pop!(ys)
    pushfirst!(ys, 0)

    xs = [0; reduce(vcat, [ [n*δ, n*δ] for n in 1:length(ps)])];

    plot!(xs, ys, label=label)
    scatter!([n*δ for n in 1:length(ps)], cumulative, label="")
	end
	
		function counts(data)
    d=Dict{Int64,Int64}()
    for i in data
        if haskey(d,i)
            d[i]+=1
            else 
            d[i]=1
        end
    end
    ks=collect(keys(d))
    vs=collect(values(d))
    p=sortperm(ks)
    
return ks[p],vs[p]
end
	
	function Canvas_Ber(lims,  N::Int64=0)
	    max=lims[end]
	    number_bins=length(lims)
	    data=[]
	    
	    p = plot(xlim=(0,max),ylim=(0,1), w=3, labels=false, ticks=false, showaxis=false, title= "Espacio muestral", xlabel="Negativo a COVID                 |                 Positivo a COVID");
		
	    
		vspan!(p,[lims[1],lims[2]], alpha = 0.2, labels = false);
		vspan!(p,[lims[2],lims[3]], alpha = 0.2, labels = false);
	    
	    return p
	end
	
	function ComparissonPlot(data, distribution; geo=0)
	
	Teorico=plot(minimum(data)-geo:1:maximum(data), x-> pdf(distribution,x), seriestype=:bar, leg=false)
	Empirico= plot(counts(data), seriestype=:bar, leg=false)
	plot(Teorico, Empirico,layout=2, title=["Teorico" "Empirico"])
	
end
	
end;


# ╔═╡ fb931c1d-3de4-489c-96d7-a69bb14fd1b2
PlutoUI.TableOfContents()

# ╔═╡ efd9c782-f1af-4b37-823f-e1a8e606f434
md" 

## Distribución Bernoulli 

### Caso Introductorio

Entenderemos la distribucion Bernoulli con un expermiento. En sala de recuperación de pacientes COVID de un hospital, se toman pruebas diarias a los pacientes para evaluar si aun presentan el virus o pueden ser dados de alta. Nosotros queremos simular el escenario de un día de un paciente. ¿Cómo hacemos esto? Consideraremos que existe una probabilidad de recuperación constante en el tiempo y le daremos un valor. Puedes usar el slider para cambiar este valor: " 

# ╔═╡ 91357e08-3a1c-41b3-9c03-1d839c3222ec

	@bind Prob Slider(0:0.05:1, default=0.25, show_value=true)

# ╔═╡ 05342071-26c0-40c4-8c7f-ff074595c6d7
md" Ya tenemos la probabilidad de recuperación, ahora simulemos la toma de la prueba. A continuacion se muestra la funcion que hará esto."

# ╔═╡ 39f0ce2f-650a-43f5-9129-0e1f4d70c215
function Prueba_Covid(p) #p es la probabilidad de recuperación
	
	prueba=rand()
	
	if prueba < p
		return "Negativo" , prueba
	else return "Positivo", prueba
	end
end

# ╔═╡ ae42451e-8ba3-47c2-8dfc-6c82cc0f7f7b
md" Presiona el boton para llamar a la función"

# ╔═╡ 450c7626-fb30-4b15-8bab-ed326698d958
@bind resultado Button("Toma la prueba COVID")

# ╔═╡ 1309cdd1-8346-4645-9156-58923aa8afed
begin
	Prueba=Prueba_Covid(Prob)
	begin resultado
		cuadro=1
		if Prueba[1]=="Positivo"
		Markdown.parse("`Resultado:  "*Prueba[1]*" a COVID-19 | El paciente no se recuperó`")
		else 
			Markdown.parse("`Resultado:  "*Prueba[1]*" a COVID-19  | El paciente se recuperó`")
		end
	end
end

# ╔═╡ 6ac7b024-ec4a-41c2-bb9b-8b3fe8c40021
md" Visualiza el espacio muestral al cambiar el valor de la probabilidad de recuperación y la aleatoriedad del experimento. "

# ╔═╡ 1cc0d686-cf69-443b-94e7-1c311b7c02ab
begin
	
	if cuadro==1
	Canvas_Ber([0,Prob,1])
	scatter!([Prueba[2]], rand(1), ms=7, labels=false, color="black")
	end
end

# ╔═╡ bbe31497-8b9c-4d6e-87b5-d0adf2bc8f5a
md"
###### Este es un experimento Bernoulli. ¡Es así de simple! 
Tenemos solo dos posibles resultados: un éxito y un fracaso.
La probabilidad con la que trabajamos es la de obtener éxito.
En nuestro ejemplo, la probabilidad que consideramos fue la de recuperarse y salir negativo a COVID, entonces, el **éxito fue asignado a este valor**. Definamos el experimento:

Experimento = Tomar la prueba COVID

Espacio muestral = [Positivo, Negativo]

Probabilidad de exito (Haberse Recuperado) = $Prob

Variable aleatoria = Estado del paciente segun la prueba realizada"

# ╔═╡ 2580129c-f92b-4ec3-a415-6d685f97111f
md"
---
### Más casos

###### Lanzamiento de una moneda
Tirar una moneda es probablemente es ejemplo de un experiemento Bernoulli mas usado. Esta vez la probabilidad de exito es 0.5.

En este caso, asignaremos el exito como obtener una cara."


# ╔═╡ 3e1b4956-7986-4835-bd11-4985ced5ab6a
@bind Moneda Button("Tira la moneda")

# ╔═╡ 3a9666e9-b549-4038-887a-4142b24af61e

begin Moneda
	rand() < 0.5 ? Resource("https://imgur.com/oiBrxLj.jpg", :width=>100) : 							Resource("https://imgur.com/lsIfpdt.jpg", :width=>100)
end


# ╔═╡ 2573ea72-8716-4575-90db-e533a59bde14
md""" 
Experimento = Lanzar la moneda

Espacio muestral = [Cara, Sello]

Probabilidad de exito (Salir positivo) = 0.5

Variable aleatoria = Resultado del lanzamiento

""" 

# ╔═╡ 5cf627ef-0c52-4e11-862a-de04f233f6be
md" 
---
### Exploremos la Teoría"

# ╔═╡ 289d89e7-3b25-4f9d-b86f-156db859801c
md"Entonces, el modelo Bernoulli describe un experimento que tiene **sólo dos resultados posibles**. Uno que llamaremos **éxito** y el otro, **fracaso**. El modelo Bernoulli utiliza el parametro **_p_**, que representa la **probabilidad de éxito**."

# ╔═╡ 502d45d4-ec81-4b3f-8e4b-ce708843af4d
md" ##### Exploremos su función de probabilidad de masa:
$$\begin{align*}
f(x) = \begin{cases} p & \text{de tomar el valor } 1\\
1-p & \text{de tomar el valor } 0\end{cases}\\
\end{align*}$$"

# ╔═╡ 32a96882-eec2-4da6-b765-591fb72e7d33
md"  💡**Nota:** Decir que tomará valor `1` **si es un éxito** o `0` **si obtenemos un fracaso**, nos ayuda a generalizar el resultado. Por ejemplo, en el caso de lanzar la moneda, ya que defininimos el éxito como obtener cara, este valor sería representado por **1** y sello estaría representado por **0**"

# ╔═╡ 8549a117-88a6-4e38-a99d-5bb6d66647a6
md"Puedes mover el slider de la probabilidad para explorar la función de probabilidad de masa en su forma gráfica:"

# ╔═╡ 086b52fb-24e8-4e5a-9a00-3d568cea960f
@bind P Slider(0:0.1:1; default=0.5, show_value=true)

# ╔═╡ 5843e3ad-d3b4-4ee1-aa96-dc2f6734d57c
TeoricBarplot(Bernoulli(P),0,2)

# ╔═╡ 37302c26-5411-4e62-9c14-b3536628d6f8
md" ##### Exploremos su función de distribución de probabilidad: "

# ╔═╡ eb08ffb6-faf4-44cf-a03a-f698c314df0c
md"
$$\begin{align*}
&F(x) = \begin{cases} 0 & 
\text{si } x<0\\ 1-p & \text{si } 0\leq x < 1\\ 1 & \text{si } x \geq 1 
\end{cases}\\
\end{align*}$$"

# ╔═╡ 0193bc92-9fdd-49ff-b63c-71230af0f036
md"Puedes mover el slider de la probabilidad para ver la funcion de distribución de probabilidad en su forma gráfica:"

# ╔═╡ b34bef02-5d88-4648-b3fa-3e06fb06f434
@bind P1 Slider(0:0.1:1; default=0.5, show_value=true)

# ╔═╡ 788be74d-10e4-49ff-b6c4-0de59d38a7cc
begin
	 	
		TeoricBarplot(Bernoulli(P1),0,2)
		plot_cumulative!([1-P1, P1],label="")
	
end

# ╔═╡ 01512d62-9e0a-4332-9376-80faca75cc3e
md"
---
### Resumen Teorico"

# ╔═╡ a06b18f7-002d-4fa7-85f1-3800aab7dc9d
md"

$$\begin{align*}
&X = \begin{cases} 1 & \text{con probabilidad  } p\\
0 & \text{con probabilidad  } 1-p\end{cases}\\
&F(x) = \begin{cases} 0 & 
\text{si } x<0\\ 1-p & \text{si } 0\leq x < 1\\ 1 & \text{si } x \geq 1 
\end{cases}\\
&E(X)=0(1-p) + 1 (p)=p\\
&Var(X)=p(1-p)
\end{align*}$$
"

# ╔═╡ dbc6dee1-b373-419a-bfb0-60a7b95447e3
md" 
---

## Distribución Binomial

### Caso Introductorio

Entenderemos la distribucion Binomial con un caso en el mismo hospital. Para el hospital es informacion valiosisima saber las probabilidades de cuantos de sus pacientes podrán ser dados de alta en un día. Para eso, debemos simular la recuperación diaria de todos sus pacientes. Ellos albergan a 100 pacientes COVID en sus instalaciones. ¿Cómo hacemos esto? Para empezar, **defininamos algunos parámetros:**"

# ╔═╡ 0fba673c-614c-4948-9889-140f4eebfbf3
md"- Número de pruebas diarias:"

# ╔═╡ 5aa0b173-f415-4157-a17b-dcf7cb07b79b

	@bind bin_pruebas NumberField(0:200, default=100)


# ╔═╡ 04f47231-7396-4c72-ac20-4fa02212c383
md" - Probabilidad de que una persona se recupere y salga negativo:"

# ╔═╡ 30f405b7-fc11-4857-b144-ee88e0b0717c
	@bind bin_prob Slider(0:0.05:1, default=0.25, show_value=true)

# ╔═╡ ef8e069f-c3de-4643-aa33-4c3fb594ccdb
md" 
💡 Recuerda que el notebook es interactivo y puedes cambiar los valores para hacer más pruebas"

# ╔═╡ 2cf03f51-d574-4efe-9546-32907e66852a
md"Podemos considerar la toma de la prueba entre personas como eventos independientes. Esto significa que estamos considerando que el progreso de un paciente no afecta en otros.

Entonces utilizaremos la función que creamos en el experimento bernoulli que simula la recuperación de un paciente en un día y la repetiremos el numero de pacientes que se encuentran en el hospital:
"

# ╔═╡ 6ce28ce9-26f1-479a-b093-1e8a61ca16f5
function Toma_de_Pruebas_Diaria(n,p)
	
	# n representa el numero de pruebas a realizar
	#p representa la probabilidad de que una de esas pruebas salga positivo
	
	registro_pacientes=[]
	
	for i in 1:n
		resultado=Prueba_Covid(p)[1]
		push!(registro_pacientes, resultado)
	end
	
	return registro_pacientes
end

# ╔═╡ f3e6a555-3d38-4325-afbf-5ff8dc0e3c52
md"Presiona el botón para simular las pruebas"

# ╔═╡ 6ee9a581-0b61-4f87-8d48-6769dc0d25b1
@bind bin_dia Button("Simula un día de pruebas")

# ╔═╡ e724289a-bbc2-4752-9904-d69845457540
begin bin_dia
	
	bin_registro=DataFrame(Pacientes=["Paciente"*string(i) for i in 1:bin_pruebas], Resultado=Toma_de_Pruebas_Diaria(bin_pruebas,bin_prob))
    bin_registro
end

# ╔═╡ 63b6571d-4021-438a-8cfe-bf4a3944e8cb
begin
	result_bin_dia=sum(bin_registro[!,2].=="Negativo")
	Markdown.parse("`Total de Negativos en un día:  "*string(result_bin_dia)*" | Pacientes Recuperados`")

end

# ╔═╡ a794d0e0-5598-446a-b37f-4bbced8c0254
md" En este dia el número de pacientes recuperados es $result_bin_dia. Vuelve a presionar el botón para apreciar la aletoriedad del expermiento. Tambien, puedes jugar con el valor de la probabilidad y el numero de pacientes.

###### Este es un experimento Binomial. ¡Es así de simple! 
Se repite **_n_** veces de manera independiente un **experimento Bernoulli** parámetro **_p_**, y se **reporta el número de éxitos** obtenidos. Ahora, definamos el experimento:

Experimento = Tomar $bin_pruebas pruebas COVID

Espacio muestral = [:Todas las combinaciones posibles]

Variable aleatoria = $X$ : Número de pruebas positivas de un total de $bin_pruebas pruebas tomadas en un dia

$ X ~ Bin( $bin_pruebas, $bin_prob) $

"

# ╔═╡ 0de8e1b6-8eac-4a5a-83b4-3313916e34e7
md"
###### Ahora repitamos el experimento muchas veces para observar su aleatoriedad y compararlo con la teoría de la distribución Binomial:

- Ingresa el número de repeticiones que deseas observar:"

# ╔═╡ 188171e4-f6e3-4847-83ff-d85cb1677562
@bind bin_rep  NumberField(0:200, default=100)

# ╔═╡ cbb87f4d-573e-4ea0-8182-4a69d3401eab
md"💡 Recomendación: Prueba repitiendolo 10 veces, aumenta a 100, a 1000, a 10000 y así para que observes lo que ocurre."

# ╔═╡ 0449916f-0d03-42c5-8f6d-61bb15064305
begin 
	data=[RandomBinomial(bin_prob, bin_rep) for i in 1:bin_rep];
	ComparissonPlot(data, Binomial(bin_rep, bin_prob))
end

# ╔═╡ 116140ef-907c-4b59-9238-93d9674f1233
md" Como podemos ver, mientras más veces repetimos el experimento, hay mayor parecido en las graficas. Exploremos la teoria detras de esto para entender un poco mejor. "

# ╔═╡ d09a3d1e-9e20-4197-ad4b-cdd63fae6772
md"
---
### Exploremos la teoría
"


# ╔═╡ ba22e820-9c8c-485c-8205-9c2e64108842
md"
###### Función de probabilidad de masa:
$$\begin{align*}
& P(X=k)=\binom{n}{k}p^{k}(1-p)^{n-k}\\ 
&k=0,1,2,\ldots , n\\
\end{align*}$$"

# ╔═╡ 778f2336-fea5-41bf-ae80-e0fca9a84678
md" Mueve los slider y observa que cambios ocurren al alterar cada parametro"

# ╔═╡ 3c4a347d-b8a5-4b83-a48e-460e8ddcac76
@bind bin_slidern1 Slider(0:20; default=10, show_value=true)

# ╔═╡ 81ce007c-359e-407b-8f93-82428048c974
@bind bin_sliderp1 Slider(0:0.1:1; default=0.5, show_value=true)

# ╔═╡ 51f0acab-0cf4-431d-a756-85f47a95a46b

TeoricBarplot(Binomial(bin_slidern1,bin_sliderp1),1,10)


# ╔═╡ 62fa4585-9438-49cb-843d-5242d62f0271
md" ##### Exploremos su función de distribución: "

# ╔═╡ f4389c9a-6173-4678-8dbe-f8f132de23fe
md"""
$$\begin{align*}

&F(x)\equiv P(X\leq x)=\sum_{k\leq x}\binom{n}{k}p^k(1-p)^{n-k}\\
&\forall x\in \mathbb{R}\\
\end{align*}$$"""


# ╔═╡ 90f96e72-8c73-4511-8354-c41ba2cf6953
begin
	pdf_bin= [pdf(Binomial(bin_slidern1, bin_sliderp1), i) for i in 1:bin_slidern1]
	plot_cumulative2!(pdf_bin, label="")
end

# ╔═╡ 49343971-0377-4d42-aca0-46f31b5db51f
md"
---
### Más casos

(Incluir ejemplos Indutriales, Algo para usar el Canvas)
"


# ╔═╡ e7c54ff8-5fbb-49a5-84d6-1f426e472f1c
md"
---
### Resumen Teórico

$$\begin{align*}
& P(X=k)=\binom{n}{k}p^{k}(1-p)^{n-k}\\ 
&k=0,1,2,\ldots , n\\
&F(x)\equiv P(X\leq x)=\sum_{k\leq x}\binom{n}{k}p^k(1-p)^{n-k}\\
&\forall x\in \mathbb{R}\\
\end{align*}$$"

# ╔═╡ 07f5624f-260f-4738-8616-a4c6f74cf7c0
md" 
---

## Distribución Geométrica

### Caso Introductorio

Entenderemos la distribución Geométrica con un caso en el mismo hospital. Queremos saber probabilidades de cuantos días pasará un paciente de COVID en el hospital. Esta es informa importante tanto para los pacientes como para el planeamiento de recursos del hospital. Entonces, ¿cómo podemos estudiar estas probabilidades? Simularemos esta situación. Recordemos que estamos considerando la probabilidad de recuperacion diaria como constante en el tiempo. Definamos este parámetro:

"

# ╔═╡ c590ff79-7ae2-4b94-9981-52e94d56e8ff
	@bind geo_prob Slider(0:0.05:1, default=0.25, show_value=true)

# ╔═╡ 1468cf1d-9d4b-45fa-897a-bfeecd51772c
md" ¿Cómo podemos saber el tiempo que estará un paciente en el hospital, si contamos con la probabilidad diaria de que sea dado de alta y deje las intalaciones? 

Debemos contar la cantidad de días que se tome la prueba hasta que esta salga negativo y pueda ser dado de alta. Entonces, escribamos una función que nos permita hacer eso: "

# ╔═╡ 38f5ac07-f21d-4792-8966-1bc92b4d7ef0
function dias_Recuperacion(p)
    dias=0
    estado="Positivo"
    while estado=="Positivo"
        estado=Prueba_Covid(p)[1]
        dias+=1
    end
    return dias
end

# ╔═╡ 8496b0d6-12b9-4728-bc91-c5b8f56ea739
@bind geo_boton Button("Simula estadía de un paciente")

# ╔═╡ 453c9c94-c56c-4208-9171-e9244cc94295
begin geo_boton
	
	geo_dias= dias_Recuperacion(geo_prob)
	Markdown.parse("`Días hasta recuperación:  "*string(geo_dias)*"`")
	
end

# ╔═╡ 3f07ba26-441c-4c21-a139-3adf298d765b
md" Puedes presionar el botón varias veces para apreciar la aleatoriedad del experimento"

# ╔═╡ 145e4c65-9e3b-4c8b-9c40-f41892fc9d7c
md"
###### Ahora repitamos el experimento muchas veces para observar su aleatoriedad y compararlo con la teoría de la distribución Geometrica:

- Ingresa el número de repeticiones que deseas observar:"

# ╔═╡ ee30e1f0-9f93-4af6-b51e-4df0de63afad
@bind geo_rep  NumberField(0:200, default=100)

# ╔═╡ e7340cda-92b7-4496-a47b-a733cc2a59b9
md"💡 Recomendación: Prueba repitiendolo 10 veces, aumenta a 100, a 1000, a 10000 y así para que observes lo que ocurre."

# ╔═╡ bb984796-fb9f-4f93-81c8-629d1107c52e
begin
	data_geo=[dias_Recuperacion(geo_prob) for i in 1:geo_rep]
	ComparissonPlot(data_geo, Geometric(geo_prob), geo=1)
	
end

# ╔═╡ c009f68e-9d39-4d41-8f47-0620ddae717c
md" Como podemos ver, mientras más veces repetimos el experimento, hay mayor parecido en las graficas. Exploremos la teoria detras de esto para entender un poco mejor."

# ╔═╡ 8b338b49-1dbf-40f3-889a-157804c87a50
begin
	scatter(data_geo, xticks=false,legend=false)
	hline!([mean(data_geo)],lw=3, ls=:dash, c=:red,leg=false)
end

# ╔═╡ 8048479d-5a08-401b-a1a0-b7c501b82927
Markdown.parse("`Promedio días de recuperación:  "*string(mean(data_geo))*"`")

# ╔═╡ 97dd5cb6-d360-4f49-b20a-9cb260e2e5b0
begin
	m=mean(data_geo)
	
	squared_data = (data_geo .- m).^2
	
	variance = mean(squared_data)
	
	Markdown.parse("`Varianza días de recuperación:  "*string(variance)*"`")
end



# ╔═╡ c2691808-685d-44a3-98ba-3ec930665851
begin
	hline!([mean(data_geo)], lw=3, ls=:dash, c=:purple,leg=false)
	hline!([mean(data_geo)+variance], lw=3, ls=:dash, c=:green,leg=false)
	hline!([mean(data_geo)-variance], lw=3, ls=:dash, c=:green,leg=false)
end

# ╔═╡ a3f31d9a-eb88-49e4-926f-6965c3b0d108
begin
	σ=sqrt(variance)
	Markdown.parse("`Desviación estandar días de recuperación:  "*string(σ)*"`")
end

# ╔═╡ 33ec9fb2-c0a6-43c3-93de-e5376b2760e7
begin
	scatter(data_geo, alpha=0.5)
	hline!([mean(data_geo)], lw=3, ls=:dash, c=:purple,leg=false)
	hline!([mean(data_geo)+σ], lw=3, ls=:dash, c=:red,leg=false)
	hline!([mean(data_geo)-σ], lw=3, ls=:dash, c=:red,leg=false)
end

# ╔═╡ 514df2eb-a1f9-4665-927c-7d74aa2f1505
md"
---
### Exploremos la teoría
"


# ╔═╡ d9ea4012-45ee-4baf-bf4f-a2b0ec71b69c
md"
###### Función de probabilidad de masa:
$$
\begin{align*}
&P(X=k)=(1-p)^{k-1}p\\
&k=1,2\ldots\\
\end{align*}$$"

# ╔═╡ 7c63a28c-9599-44eb-a144-45ec2eff4dfb
md"Mueve el slider para cambiar el valor de p"

# ╔═╡ f72fd27b-3f9a-4f3f-a412-71b37797d4dd
@bind geo_prob2 Slider(0:0.05:1, default=0.5, show_value=true)

# ╔═╡ 81ba5f86-6762-4b8f-ba64-a4779c7c65d1
TeoricBarplot(Geometric(geo_prob2),1,20, 0.35, auto=true, geo=1)

# ╔═╡ 23eead02-a4bd-43b3-9dfb-0f83a9acc3ef
md"
###### Función de distribuacion acumulada:
$$
\begin{align*}
&F(x)\equiv P(X\leq x)=\sum_{k\leq x}(1-p)^{k-1}p\\
&\forall x\in \mathbb{R}
\end{align*}$$"

# ╔═╡ 21a292db-3871-4133-8396-67e5ebc1c509
begin
	TeoricBarplot(Geometric(geo_prob2),1, 20,1, geo=1)
	pdf_geo= [pdf(Geometric(geo_prob2), i) for i in 0:20]
	plot_cumulative2!(pdf_geo, label="")
end

# ╔═╡ 0b4e7950-5e5b-4056-987e-c6d93546bd48
md"
---
### Resumen Teórico

$$
\begin{align*}
&P(X=k)=(1-p)^{k-1}p\\
&k=1,2\ldots\\
&F(x)\equiv P(X\leq x)=\sum_{k\leq x}(1-p)^{k-1}p\\
&\forall x\in \mathbb{R}\\
&E(X)=\sum_{k=1}^\infty 
kp(k)= \sum_{k=1}^\infty k(1-p)^{k-1}p=\frac{1}{p}\\
&Var(X)=\frac{1-p}{p^2}\\
\end{align*}$$"

# ╔═╡ e4399d37-e193-4d64-9280-6356cb84fb71
md"## Distribución Poisson

Caso Introductorio:

Entenderemos la distribución Poisson simulando las llegadas de Pacientes COVID al hospital...

"

# ╔═╡ f61f9db3-b6a5-4dbf-a195-3d9cb3cbf9b3
md"
---
### Exploremos la teoría
"

# ╔═╡ 8903b303-2926-4064-9a58-d9d6329883fd

md"
###### Función de probabilidad de masa:
$P(X=x)=\frac{e^{-\lambda}\lambda^x}{x!} 
\quad x=0,1,2\ldots$"



# ╔═╡ 44674e1a-e2ae-415a-802d-740751cd0949
md"Mueve el slider para cambiar el valor del parametro"

# ╔═╡ ae6a2835-6b02-4e7f-986a-e5ccfc728f93
@bind poiss_lambda Slider(0:1:100, default=20, show_value=true)

# ╔═╡ a5fff464-9b3e-4cdd-9cf9-332736269ff7
TeoricBarplot(Poisson(poiss_lambda),0.3*poiss_lambda , 1.5*poiss_lambda , 0.05)

# ╔═╡ 153ad89f-de01-4963-91cb-fe2c2b842eb9
md"
###### Función de distribución acumulada:
$F(x)=P(X\leq x)=\sum_{k=0}^{\left\lfloor
x\right\rfloor}\frac{e^{-\lambda}\lambda^k}{k!}$"

# ╔═╡ 9092b7a7-d5bd-45bc-99a1-19f545aacb1d
begin
	TeoricBarplot(Poisson(poiss_lambda),0 , 1.7*poiss_lambda , 0.9)
	pdf_poiss= [pdf(Poisson(poiss_lambda), i) for i in 0: 1.7*poiss_lambda]
	plot_cumulative2!(pdf_poiss, label="")
end

# ╔═╡ 7b4b1265-83af-42c6-86dc-70126460bfde
md"
---
### Resumen Teórico


$\text{f.p.m.} \quad P(X=x)=\frac{e^{-\lambda}\lambda^x}{x!} 
\quad x=0,1,2\ldots$

$\text{f.d.a.} \quad F(x)=P(X\leq x)=\sum_{k=0}^{\left\lfloor
x\right\rfloor}\frac{e^{-\lambda}\lambda^k}{k!}$

$E(X)=\sum_{k=0}^\infty 
k\frac{e^{-\lambda}\lambda^k}{k!}=\sum_{k=1}^\infty 
k\frac{e^{-\lambda}\lambda^{k-1}\lambda}{(k-1)!}=\lambda 
e^{-\lambda}e^\lambda=\lambda$

$Var(X)=\lambda$
"

# ╔═╡ 9c00f83b-e97a-42ec-bc7f-5c95138d100f
md"""
# Distribuciones continuas
"""

# ╔═╡ 4c5b357e-d4c5-4f72-8b35-bbd1824da232
md"""
p = $(@bind p Slider(0.1:0.05:1, default=.2, show_value=true))
"""

# ╔═╡ 6c1c43e7-96d9-4c70-bc95-dfe683d4af7e
md"""
N = $(@bind N Slider(10:10:100, default=20, show_value=true))
"""

# ╔═╡ be5a0d38-f24b-40ac-92a0-faf9e608024e
md"""
δ = $(@bind δ Slider(0.1:0.05:1, default=1, show_value=true))
"""

# ╔═╡ 296f430f-7129-4d8f-84b2-6c398efb4ebe
begin
	continua_pdf(p, N) = [p * (1 - p)^(n-1) for n in 1:N]
	plot()
	plot_cumulative!(continua_pdf(p, N), 1, label="delta = 1")
	plot_cumulative!(continua_pdf(p, N), δ, label="delta = $(δ)")
end

# ╔═╡ de4c95d8-894c-47b7-99ad-0959ffa674ab
md"""
## Exponencial
"""

# ╔═╡ d237deda-a25d-45d3-817a-7019dd0dd15c
md"""
λ = $(@bind λ Slider(0:1:50, default=1, show_value=true))
"""

# ╔═╡ 793a2fb0-9f23-41db-b4af-bfe363218b86
md""" t = $(@bind t Slider(1:0.5:50, default=5, show_value=true)) """

# ╔═╡ 35b8cac6-3ffc-4676-bee3-7b9c428362f9
begin
	densidad_exponencial(t) = λ * exp(-λ * t);
	probabilidad_exponencial(t) = 1 - exp(-λ * t);
end;

# ╔═╡ 88870c07-b603-40de-b398-64cbed17fa38
md"""
Selecciona una función: $(@bind exp_func Select([
	"Densidad", "Probabilidad"
]))
"""

# ╔═╡ fed32500-1c8f-4875-8831-87b0ea9763de
f(t) = exp_func == "Densidad" ? densidad_exponencial(t) : probabilidad_exponencial(t);

# ╔═╡ e9939368-a08f-4994-a823-c1b6b72b9814
range = 2:0.1:t;

# ╔═╡ f48ab57e-5ca7-4be8-af30-a6626dd9ed40
begin
	plot()
	plot(0:0.1:t, f)
	plot!(range, f, fill=true, alpha=0.4, legend=false)
end

# ╔═╡ f73f3507-03ac-4957-9cba-082b61d462ef
md"## Distribucion uniforme"

# ╔═╡ 93de82c3-e3d6-47ee-bcdb-5926e1447aca
md"Caso Introdutorio: "

# ╔═╡ d8633435-5c37-4d78-89da-001efbfa6829
uniform(a, b) = a + rand() * (b - a)

# ╔═╡ ef25478e-e577-4e3c-8de8-df0f4de115e3
@bind datos_unif NumberField(0:200, default=100)

# ╔═╡ b3d48ffe-5d88-491e-bf8d-695aa17f356e
md"Mínimo (a):"

# ╔═╡ 1e6dff27-ccba-48c8-b015-411b334e63bb
@bind unif_min NumberField(0:200, default=0)

# ╔═╡ f46bfb4c-93b1-4fc6-9e8e-4579996ed3fb
md"Máximo (b):"

# ╔═╡ 4c25ea05-a4b0-4cb3-98f0-b19ffb75f2a8
@bind unif_max NumberField(0:200, default=1)

# ╔═╡ 8c993fe9-2719-4825-adf7-fc07c43b349d
begin
	data_unif = [uniform(unif_min, unif_max) for i in 1:datos_unif];
	histogram(data_unif, nbins=20, legend=false)  # function in Plots.jl
	scatter!(data_unif, zero.(data_unif), ms=2, alpha=0.3)
end

# ╔═╡ c0c22c1f-7508-40bd-bda7-afaeda8d58b2
md"
---
### Exploremos la teoría
"

# ╔═╡ 8e7dba6d-8f35-47d8-afda-2c36d1313a4a
md"
###### Función de densidad de probabilidad:
$$
\begin{align*}
f(x) &= \begin{cases}
\frac{1}{b - a} & \text{ si } a \leq x \leq b \\\\ 
              0 & \text{ fuera }\\\\
        \end{cases}
\end{align*}$$"

# ╔═╡ 2829a895-7de5-47dd-a97a-5c9b2da1a59e
md"Coloca el mínimo y máximo"

# ╔═╡ 93c6323a-7dac-4174-aea5-139cc38283f4
@bind a NumberField(0:200, default=0)

# ╔═╡ 61a15261-b13f-46a5-9a01-3c18d0245e23
@bind b NumberField(0:200, default=1)

# ╔═╡ e9b56895-7ea0-4ac6-90df-4b77bfa30e02
begin
	plot(vcat([a-0.2,a],[ i+0.1 for i in a-0.1:0.1:b-0.1],[b,b+0.2]), vcat([0,0],[pdf(Uniform(a,b),i) for i in a:0.1:b],[0,0]), legend=false, ylims=(0,1), yticks= [1/b-a], linewidth=3)
end

# ╔═╡ 877346f2-d025-4330-adaa-7585af22a653
md"
###### Función de distribución acumulada:
$$
\begin{align*}
F(x) \equiv & P(X\leq x)= \int_{a}^{x}\frac{1}{b-a}dt\\\\
          = & \begin{cases}
                0 & \text{ si } x < a\\\\
                \frac{x-a}{b - a} & \text{ si } a \leq x \leq b\\\\
                1 & \text{ si } x > b
              \end{cases}
\end{align*}$$"

# ╔═╡ Cell order:
# ╟─aacc06b4-1afb-4e83-8392-45b2e24eb51a
# ╠═1e264b46-fd83-4ee0-952a-544d38a7ac76
# ╟─d0ae819a-d96a-4715-86f0-e6e480d0714b
# ╠═fb931c1d-3de4-489c-96d7-a69bb14fd1b2
# ╟─efd9c782-f1af-4b37-823f-e1a8e606f434
# ╟─91357e08-3a1c-41b3-9c03-1d839c3222ec
# ╟─05342071-26c0-40c4-8c7f-ff074595c6d7
# ╠═39f0ce2f-650a-43f5-9129-0e1f4d70c215
# ╟─ae42451e-8ba3-47c2-8dfc-6c82cc0f7f7b
# ╟─450c7626-fb30-4b15-8bab-ed326698d958
# ╟─1309cdd1-8346-4645-9156-58923aa8afed
# ╟─6ac7b024-ec4a-41c2-bb9b-8b3fe8c40021
# ╟─1cc0d686-cf69-443b-94e7-1c311b7c02ab
# ╟─bbe31497-8b9c-4d6e-87b5-d0adf2bc8f5a
# ╟─2580129c-f92b-4ec3-a415-6d685f97111f
# ╟─3a9666e9-b549-4038-887a-4142b24af61e
# ╟─3e1b4956-7986-4835-bd11-4985ced5ab6a
# ╟─2573ea72-8716-4575-90db-e533a59bde14
# ╟─5cf627ef-0c52-4e11-862a-de04f233f6be
# ╟─289d89e7-3b25-4f9d-b86f-156db859801c
# ╟─502d45d4-ec81-4b3f-8e4b-ce708843af4d
# ╟─32a96882-eec2-4da6-b765-591fb72e7d33
# ╟─8549a117-88a6-4e38-a99d-5bb6d66647a6
# ╟─086b52fb-24e8-4e5a-9a00-3d568cea960f
# ╟─5843e3ad-d3b4-4ee1-aa96-dc2f6734d57c
# ╟─37302c26-5411-4e62-9c14-b3536628d6f8
# ╟─eb08ffb6-faf4-44cf-a03a-f698c314df0c
# ╟─0193bc92-9fdd-49ff-b63c-71230af0f036
# ╟─b34bef02-5d88-4648-b3fa-3e06fb06f434
# ╟─788be74d-10e4-49ff-b6c4-0de59d38a7cc
# ╟─01512d62-9e0a-4332-9376-80faca75cc3e
# ╟─a06b18f7-002d-4fa7-85f1-3800aab7dc9d
# ╟─dbc6dee1-b373-419a-bfb0-60a7b95447e3
# ╟─0fba673c-614c-4948-9889-140f4eebfbf3
# ╟─5aa0b173-f415-4157-a17b-dcf7cb07b79b
# ╟─04f47231-7396-4c72-ac20-4fa02212c383
# ╟─30f405b7-fc11-4857-b144-ee88e0b0717c
# ╟─ef8e069f-c3de-4643-aa33-4c3fb594ccdb
# ╟─2cf03f51-d574-4efe-9546-32907e66852a
# ╠═6ce28ce9-26f1-479a-b093-1e8a61ca16f5
# ╟─f3e6a555-3d38-4325-afbf-5ff8dc0e3c52
# ╟─6ee9a581-0b61-4f87-8d48-6769dc0d25b1
# ╟─63b6571d-4021-438a-8cfe-bf4a3944e8cb
# ╟─e724289a-bbc2-4752-9904-d69845457540
# ╟─a794d0e0-5598-446a-b37f-4bbced8c0254
# ╟─0de8e1b6-8eac-4a5a-83b4-3313916e34e7
# ╟─188171e4-f6e3-4847-83ff-d85cb1677562
# ╟─cbb87f4d-573e-4ea0-8182-4a69d3401eab
# ╟─0449916f-0d03-42c5-8f6d-61bb15064305
# ╟─116140ef-907c-4b59-9238-93d9674f1233
# ╟─d09a3d1e-9e20-4197-ad4b-cdd63fae6772
# ╟─ba22e820-9c8c-485c-8205-9c2e64108842
# ╟─778f2336-fea5-41bf-ae80-e0fca9a84678
# ╟─3c4a347d-b8a5-4b83-a48e-460e8ddcac76
# ╟─81ce007c-359e-407b-8f93-82428048c974
# ╟─51f0acab-0cf4-431d-a756-85f47a95a46b
# ╟─62fa4585-9438-49cb-843d-5242d62f0271
# ╟─f4389c9a-6173-4678-8dbe-f8f132de23fe
# ╟─90f96e72-8c73-4511-8354-c41ba2cf6953
# ╟─49343971-0377-4d42-aca0-46f31b5db51f
# ╟─e7c54ff8-5fbb-49a5-84d6-1f426e472f1c
# ╟─07f5624f-260f-4738-8616-a4c6f74cf7c0
# ╟─c590ff79-7ae2-4b94-9981-52e94d56e8ff
# ╟─1468cf1d-9d4b-45fa-897a-bfeecd51772c
# ╠═38f5ac07-f21d-4792-8966-1bc92b4d7ef0
# ╟─8496b0d6-12b9-4728-bc91-c5b8f56ea739
# ╟─453c9c94-c56c-4208-9171-e9244cc94295
# ╟─3f07ba26-441c-4c21-a139-3adf298d765b
# ╟─145e4c65-9e3b-4c8b-9c40-f41892fc9d7c
# ╟─ee30e1f0-9f93-4af6-b51e-4df0de63afad
# ╟─e7340cda-92b7-4496-a47b-a733cc2a59b9
# ╟─bb984796-fb9f-4f93-81c8-629d1107c52e
# ╟─c009f68e-9d39-4d41-8f47-0620ddae717c
# ╟─8b338b49-1dbf-40f3-889a-157804c87a50
# ╟─8048479d-5a08-401b-a1a0-b7c501b82927
# ╟─97dd5cb6-d360-4f49-b20a-9cb260e2e5b0
# ╟─c2691808-685d-44a3-98ba-3ec930665851
# ╟─a3f31d9a-eb88-49e4-926f-6965c3b0d108
# ╟─33ec9fb2-c0a6-43c3-93de-e5376b2760e7
# ╟─514df2eb-a1f9-4665-927c-7d74aa2f1505
# ╟─d9ea4012-45ee-4baf-bf4f-a2b0ec71b69c
# ╟─7c63a28c-9599-44eb-a144-45ec2eff4dfb
# ╟─f72fd27b-3f9a-4f3f-a412-71b37797d4dd
# ╟─81ba5f86-6762-4b8f-ba64-a4779c7c65d1
# ╟─23eead02-a4bd-43b3-9dfb-0f83a9acc3ef
# ╟─21a292db-3871-4133-8396-67e5ebc1c509
# ╟─0b4e7950-5e5b-4056-987e-c6d93546bd48
# ╟─e4399d37-e193-4d64-9280-6356cb84fb71
# ╟─f61f9db3-b6a5-4dbf-a195-3d9cb3cbf9b3
# ╟─8903b303-2926-4064-9a58-d9d6329883fd
# ╟─44674e1a-e2ae-415a-802d-740751cd0949
# ╟─ae6a2835-6b02-4e7f-986a-e5ccfc728f93
# ╟─a5fff464-9b3e-4cdd-9cf9-332736269ff7
# ╟─153ad89f-de01-4963-91cb-fe2c2b842eb9
# ╟─9092b7a7-d5bd-45bc-99a1-19f545aacb1d
# ╟─7b4b1265-83af-42c6-86dc-70126460bfde
# ╟─9c00f83b-e97a-42ec-bc7f-5c95138d100f
# ╟─4c5b357e-d4c5-4f72-8b35-bbd1824da232
# ╟─6c1c43e7-96d9-4c70-bc95-dfe683d4af7e
# ╟─be5a0d38-f24b-40ac-92a0-faf9e608024e
# ╟─296f430f-7129-4d8f-84b2-6c398efb4ebe
# ╟─de4c95d8-894c-47b7-99ad-0959ffa674ab
# ╟─d237deda-a25d-45d3-817a-7019dd0dd15c
# ╟─793a2fb0-9f23-41db-b4af-bfe363218b86
# ╠═35b8cac6-3ffc-4676-bee3-7b9c428362f9
# ╟─88870c07-b603-40de-b398-64cbed17fa38
# ╟─fed32500-1c8f-4875-8831-87b0ea9763de
# ╠═e9939368-a08f-4994-a823-c1b6b72b9814
# ╟─f48ab57e-5ca7-4be8-af30-a6626dd9ed40
# ╟─f73f3507-03ac-4957-9cba-082b61d462ef
# ╟─93de82c3-e3d6-47ee-bcdb-5926e1447aca
# ╠═d8633435-5c37-4d78-89da-001efbfa6829
# ╟─ef25478e-e577-4e3c-8de8-df0f4de115e3
# ╟─b3d48ffe-5d88-491e-bf8d-695aa17f356e
# ╟─1e6dff27-ccba-48c8-b015-411b334e63bb
# ╟─f46bfb4c-93b1-4fc6-9e8e-4579996ed3fb
# ╟─4c25ea05-a4b0-4cb3-98f0-b19ffb75f2a8
# ╟─8c993fe9-2719-4825-adf7-fc07c43b349d
# ╟─c0c22c1f-7508-40bd-bda7-afaeda8d58b2
# ╟─8e7dba6d-8f35-47d8-afda-2c36d1313a4a
# ╟─2829a895-7de5-47dd-a97a-5c9b2da1a59e
# ╟─93c6323a-7dac-4174-aea5-139cc38283f4
# ╟─61a15261-b13f-46a5-9a01-3c18d0245e23
# ╟─e9b56895-7ea0-4ac6-90df-4b77bfa30e02
# ╟─877346f2-d025-4330-adaa-7585af22a653
