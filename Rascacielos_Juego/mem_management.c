/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   mem_management.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: eamor-di <eamor-di@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/19 17:35:25 by adride-l          #+#    #+#             */
/*   Updated: 2025/07/20 21:48:03 by eamor-di         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_rush01.h"

/* Se reserva la memoria de la matriz. Que es un array de punteros que cada
	puntero apunta a un array de integers (las filas de la matriz)
*/
int	**malloc_matrix(void)
{
	int	**matrix;
	int	row;
	int	col;

	matrix = malloc(sizeof(int *) * 4);
	if (!matrix)
		return (NULL);
	row = -1;
	while (++row < 4)
	{
		matrix[row] = malloc(sizeof(int) * 4);
		if (!matrix[row])
			return (NULL);
		col = -1;
		while (++col < 4)
			matrix[row][col] = 0;
	}
	return (matrix);
}

/* Donde guardaremos los parametros de entrada, convirtiendo
	cada caracter a int. Como en la anterior función,
	reservamos memoria con malloc (16 espacios y que cada espacio
	sea de tamaño 4B)
*/
int	*views_array(char *str)
{
	int	*views;
	int	row;

	views = malloc(sizeof(int) * 16);
	if (!views)
		return (NULL);
	row = 0;
	while (*str && row < 16)
	{
		if (*str >= '1' && *str <= '4')
		{
			views[row] = *str - '0';
			row++;
		}
		else if (*str != ' ')
			return (free(views), NULL);
		str++;
	}
	if (row != 16)
		return (free(views), NULL);
	return (views);
}

/*	Las dos siguientes funciones liberan el espacio de memoria,
	por cada fila (en la matriz) hay
	que hacer un free
*/
void	free_array(int *array)
{
	free(array);
}

void	free_matrix(int **matrix)
{
	int	row;

	row = 0;
	while (row < 4)
		free_array(matrix[row++]);
	free(matrix);
}
