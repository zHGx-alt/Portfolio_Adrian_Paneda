/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   check_functions.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: eamor-di <eamor-di@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/19 17:35:13 by adride-l          #+#    #+#             */
/*   Updated: 2025/07/20 21:49:01 by eamor-di         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_rush01.h"

/*	Esta función te mira si existe ese número en su linea o en su columna*/
int	is_already_there(int **matrix, int row, int col, int num)
{
	int	count;

	count = -1;
	while (++count < 4)
		if (matrix[row][count] == num || matrix[count][col] == num)
			return (0);
	return (1);
}

/*	Estas función te mira si cumple con las vistas.
	El proceso es el siguiente:
	1.) Mira la vista de la izquierda
	2.) Mira la vista de la derecha
	3.) Mira la vista de arriba
	4.) Mira la vista de abajo
*/
int	check_views(int **matrix, int *views)
{
	int	row;
	int	colum_array[4];
	int	rev[4];

	row = -1;
	while (++row < 4)
	{
		if (count_visible(matrix[row]) != views[8 + row])
			return (0);
		reverse(matrix[row], rev);
		if (count_visible(rev) != views[12 + row])
			return (0);
		fill_column(matrix, row, colum_array);
		if (count_visible(colum_array) != views[row])
			return (0);
		reverse(colum_array, rev);
		if (count_visible(rev) != views[4 + row])
			return (0);
	}
	return (1);
}
